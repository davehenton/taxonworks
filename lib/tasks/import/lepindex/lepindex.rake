require 'fileutils'

# require 'ruby-prof'

### rake tw:project_import:lepindex:import_all_lep_index data_directory=/Users/proceps/src/sf/import/lep_index/ no_transaction=true

namespace :tw do
  namespace :project_import do
    namespace :lepindex do

      # @import_name = 'lepindex'

      # A utility class to index data.
      class ImportedData
        attr_accessor :people_index, :user_index, :publications_index, :citations_index, :genera_index, :images_index,
          :parent_id_index, :statuses, :taxonno_index, :citation_to_publication_index, :image_index_filename

        def initialize()
          @people_index = {}                  # PeopleID -> Person object
          @user_index = {}                    # PeopleID -> User object
          @publications_index = {}            # unique_fields hash -> Surce object
          @citations_index = {}               # NEW_REF_ID -> row
          @citation_to_publication_index = {} # NEW_REF_ID -> source.id
          @genera_index = {}                  # GENUS_NUMBER -> row
          @images_index = {}                  # TaxonNo -> row
          @parent_id_index = {}               # Rank:TaxonName -> Taxon.id
          @statuses = {}                    
          @taxonno_index = {}                 #TaxonNo -> Taxon.id
          @image_index_filename = 'image_index.tab'
        end
      end

      task import_images: [:environment, :data_directory, :user_id, :project_id] do |t|
        path = @args[:data_directory] + 'image_index.tab' #  @data.image_index_filename 

        start_row = ENV['start_row'] 
        start_row ||= 1

        transaction_size = 20
        i = 1

        file = CSV.foreach(path, col_sep: "\t")
        file.each_slice(transaction_size) do |slice|
          next if i < start_row

          begin
            ApplicationRecord.transaction do 
              slice.each do |row|
                id = row[0]
                f = row[1]

                if File.exists?(f)
                 
                  if Depiction.joins(:image).where(images: {image_file_fingerprint: Digest::MD5.file(f).hexdigest }, project_id: $project_id).any?
                    puts Rainbow("#{f} for #{id} exists as depiction, skipping\n").red
                    next
                  end

                  puts "processing #{f}, for #{id}"

                  begin
                    image = Image.new(image_file: File.open(f))
                    Depiction.create!(image_attributes: { image_file: f }, depiction_object_id: id, depiction_object_type: 'TaxonName')
                  ensure
                    f.close
                  end

                else
                  puts Rainbow("Error: Can not find image #{f}, for id: #{id}, skipping!").red
                end
              end
              puts Rainbow('group handled').yellow
              i += transaction_size 
            end

          rescue ActiveRecord::RecordInvalid
            puts Rainbow("\nrecord is invalid, group is aborted").red
            raise
          end
        end
      end

      task import_all_lep_index: [:data_directory, :environment] do |t|

        @list_of_relationships = []

        @relationship_classes = {
          'type species' => 'TaxonNameRelationship::Typification::Genus',
          'by absolute tautonymy' => 'TaxonNameRelationship::Typification::Genus::Tautonomy::Absolute',
          'by monotypy' => 'TaxonNameRelationship::Typification::Genus::Monotypy::Original',
          'by original designation' => 'TaxonNameRelationship::Typification::Genus::OriginalDesignation',
          'by subsequent designation' => 'TaxonNameRelationship::Typification::Genus::Tautonomy',
          'by subsequent monotypy' => 'TaxonNameRelationship::Typification::Genus::Monotypy::Subsequent',
          'Incorrect original spelling' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling',
          'Incorrect subsequent spelling' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling',
          'Junior objective synonym' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective',
          'Junior subjective synonym' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective',
          'Junior subjective Synonym' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective',
          'Misidentification' => 'TaxonNameRelationship::Iczn::Invalidating::Misapplication',
          'Nomen nudum: Published as synonym and not validated before 1961' => 'TaxonNameRelationship::Iczn::Invalidating',
          'Objective replacement name: Junior subjective synonym' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective',
          'Unnecessary replacement name' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnnecessaryReplacementName',
          'Suppressed name' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression',
          'Unavailable name: pre-Linnean' => 'TaxonNameRelationship::Iczn::Invalidating',
          'Unjustified emendation' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation',
          'Objective replacement name: Valid Name' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym',
          'Hybrid' => '',
          'Junior homonym' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym',
          'Junior Homonym' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym',
          'Manuscript name' => '',
          'Nomen nudum' => '',
          'Nomen nudum: no description' => '',
          'Nomen nudum: No type fixation after 1930' => '',
          'Unavailable name: Infrasubspecific name' => '',
          'Unavailable name: infrasubspecific name' => '',
          'Suppressed name: ICZN official index of rejected and invalid works' => '',
          'Valid Name' => '',
          'Valid name' => '', # tweak to handle alternate form
          'Original_Genus' => 'TaxonNameRelationship::OriginalCombination::OriginalGenus',
          'OrigSubgen' => 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus',
          'Original_Species' => 'TaxonNameRelationship::OriginalCombination::OriginalSpecies',
          'Original_Subspecies' => 'TaxonNameRelationship::OriginalCombination::OriginalSubspecies',
          'Original_Infrasubspecies' => 'TaxonNameRelationship::OriginalCombination::OriginalVariety',
          'Incertae sedis' => 'TaxonNameRelationship::Iczn::Validating::UncertainPlacement',
          'Objective replacement name: Valid name' => 'TaxonNameRelationship::Iczn::PotentiallyValidating::ReplacementName',
          'Suppressed name: ICZN official index of unavailable names' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression',
          'Nomen oblitum' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName',
          'Nomen nudum: ICZN no description' => '',
          'Nomen nudum: No diagnosis after 1930' => '',
          'Unavailable name: not noun in nominative singular' => '',
          'Suppressed name: Official Index of Rejected and Invalid Works' => '',
          'Unavailable name: non binomial' => ''
        }.freeze

        @classification_classes = {
          'Hybrid' => 'TaxonNameClassification::Iczn::Unavailable::Excluded::NameForHybrid',
          'Junior homonym' => 'TaxonNameClassification::Iczn::Available::Invalid::Homonym',
          'Manuscript name' => 'TaxonNameClassification::Iczn::Unavailable::Excluded::TemporaryName',
          'Nomen nudum' => 'TaxonNameClassification::Iczn::Unavailable::NomenNudum',
          'Nomen nudum: no description' => 'TaxonNameClassification::Iczn::Unavailable::NomenNudum::NoDescription',
          'Nomen nudum: No type fixation after 1930' => 'TaxonNameClassification::Iczn::Unavailable::NomenNudum::NoTypeFixationAfter1930',
          'Nomen nudum: Published as synonym and not validated before 1961' => 'TaxonNameClassification::Iczn::Unavailable::NomenNudum::PublishedAsSynonymAndNotValidatedBefore1961',
          'Unavailable name: Infrasubspecific name' => 'TaxonNameClassification::Iczn::Unavailable::Excluded::Infrasubspecific',
          'Unavailable name: infrasubspecific name' => 'TaxonNameClassification::Iczn::Unavailable::Excluded::Infrasubspecific',
          'Unavailable name: pre-Linnean' => 'TaxonNameClassification::Iczn::Unavailable::PreLinnean',
          'Suppressed name: ICZN official index of rejected and invalid works' => 'TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedAndInvalidWorksInZoology',
          'not latin' => 'TaxonNameClassification::Iczn::Unavailable::NotLatin',
          'Suppressed name: ICZN official index of unavailable names' => 'TaxonNameClassification::Iczn::Unavailable::Suppressed',
          'Nomen nudum: ICZN no description' => 'TaxonNameClassification::Iczn::Unavailable::NomenNudum::NoDescription',
          'Nomen nudum: No diagnosis after 1930' => 'TaxonNameClassification::Iczn::Unavailable::NomenNudum::NoDiagnosisAfter1930',
          'Unavailable name: not noun in nominative singular' => 'TaxonNameClassification::Iczn::Unavailable::NotNounInNominativeSingular',
          'Suppressed name: Official Index of Rejected and Invalid Works' => 'TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedAndInvalidWorksInZoology',
          'Unavailable name: non binomial' => 'TaxonNameClassification::Iczn::Unavailable::NonBinomial'
        }.freeze

        if ENV['no_transaction']
          puts 'Importing without a transaction (data will be left in the database).'
          main_build_loop_lepindex
        else

          ApplicationRecord.transaction do
            begin
              main_build_loop_lepindex
            rescue
              raise
            end
          end

        end
      end

      def main_build_loop_lepindex
        puts Rainbow("\nStart time: #{Time.now}\n").yellow

        # @import = Import.find_or_create_by(name: @import_name)
        # @import.metadata ||= {}

        @data =  ImportedData.new

        puts Rainbow(@args).gray

        Utilities::Files.lines_per_file(Dir["#{@args[:data_directory]}/**/*.txt"])

        handle_projects_and_users_lepindex
        handle_references_lepindex
        handle_list_of_genera_lepindex
        handle_images_lepindex
        handle_species_lepindex

        # soft_validations_lepindex

        puts Rainbow("\n\n !! Success. End time: #{Time.now} \n\n").yellow
      end

      # Always build a new project, but look for an old user
      def handle_projects_and_users_lepindex
        $user_id, $project_id = nil, nil

        print "\nHandling projects and users "
        email = 'i.kitching@nhm.ac.uk'
        user_name = 'Ian Kitching'

        project_name = 'Lepindex' +  Time.now.to_s

        user = User.where(email: email).first
        user ||= User.create!(email: email, password: '3242341aas', password_confirmation: '3242341aas', name: user_name, self_created: true, flagged_for_password_reset: true)
        $user_id = user.id

        # Always start with a new project 
        project = Project.create!(name: project_name)
        $project_id = project.id
        raise Rainbow('$project_id or $user_id not set.').red  if $project_id.nil? || $user_id.nil?      

        pm = ProjectMember.create!(user: user, project: project, is_project_administrator: true)

        root = project.root_taxon_name # Protonym.find_or_create_by(name: 'Root', rank_class: 'NomenclaturalRank', project_id: $project_id)

        @lepidoptera = Protonym.create!(name: 'Lepidoptera', parent_id: root.id, rank_class: 'NomenclaturalRank::Iczn::HigherClassificationGroup::Order')

        @lepindex_imported = Keyword.create!(name: 'Lepindex_imported', definition: 'Imported from Lepindex database.')

        @data.user_index['0'] = user
        @data.user_index[''] = user
        @data.user_index[nil] = user
      end

      def handle_references_lepindex
        # BUTMOTH_SPECIESFILE_REFS_UNIQUE.txt  (Butterflies & Moths Generic Index)
        #
        # # NEW_REF_ID
        # AUTHOR
        # IN_AUTHOR
        # PUBLICATION_YEAR
        # PUBLICATION_MONTH
        # PRINTED_DATE
        # FULLTITLE
        # PUBLISHER_ADDRESS
        # PUBLISHER_NAME
        # PUBLISHER_INSTITUTE
        # SERIES
        # VOLUME
        # PART
        # PAGE
        # BHLPage

        path = @args[:data_directory] + 'BUTMOTH_SPECIESFILE_REFS_UNIQUE.txt'
        print "\nHandling references\n"
        raise "file #{path} not found" if not File.exists?(path)

        # TODO: use a converter here (blank cells)

        file = CSV.foreach(path, col_sep: "\t", encoding: 'iso-8859-1:UTF-8', headers: true)

        unique_fields =%w{AUTHOR IN_AUTHOR PUBLICATION_YEAR PUBLICATION_MONTH PRINTED_DATE FULLTITLE PUBLISHER_ADDRESS PUBLISHER_NAME PUBLISHER_INSTITUTE SERIES VOLUME PART}.freeze

        month_list = %w{January Fabruary March April May June July August September October November December}.freeze

        file.each_with_index do |row, i|
          print "\r#{i}"

          tmp = {}

          unique_fields.each do |c|
            unless row[c].blank?
              tmp[c] = row[c] 
            end
          end

          if @data.publications_index[tmp].nil?
            url = row['BHLPage'].blank? ? nil : row['BHLPage']
            source = Source::Bibtex.new( address: tmp['PUBLISHER_ADDRESS'],
                                        publisher: tmp['PUBLISHER_NAME'],
                                        series: tmp['SERIES'],
                                        institution: tmp['PUBLISHER_INSTITUTE'],
                                        volume: tmp['VOLUME'],
                                        title: tmp['FULLTITLE'],
                                        number: tmp['PART'],
                                        url: url,
                                        bibtex_type: 'article',
                                        project_sources_attributes: [{project_id: $project_id }]
                                       )

            if tmp['PUBLICATION_YEAR'] =~/\A\d\d\d\d\z/
              source.year = tmp['PUBLICATION_YEAR']
            elsif !tmp['PUBLICATION_YEAR'].blank?
              source.data_attributes.new(import_predicate: 'PUBLICATION_YEAR', value: tmp['PUBLICATION_YEAR'], type: 'ImportAttribute')
            end

            if tmp['PRINTED_DATE'] =~/\A\d\d\d\d\z/
              source.stated_year = tmp['PRINTED_DATE']
            elsif !tmp['PRINTED_DATE'].blank?
              source.data_attributes.new(import_predicate: 'PRINTED_DATE', value: tmp['PRINTED_DATE'], type: 'ImportAttribute')
            end

            if month_list.include?(tmp['PUBLICATION_MONTH'])
              source.month = tmp['PUBLICATION_MONTH']
            elsif !tmp['PUBLICATION_MONTH'].blank?
              source.data_attributes.new(import_predicate: 'PUBLICATION_MONTH', value: tmp['PUBLICATION_MONTH'], type: 'ImportAttribute') # !? is this adding to source?
            end

            source.author = tmp['IN_AUTHOR'].blank? ? tmp['AUTHOR'] : tmp['IN_AUTHOR']

            source.save!
            source_id = source.id

            @data.publications_index[tmp] = source_id
          else
            # was source = ?!
            source_id = @data.publications_index[tmp]
          end

          @data.citations_index[row['NEW_REF_ID']] = row
          @data.citation_to_publication_index[row['NEW_REF_ID']] = source_id
        end

        #file.close

        GC.start
        puts "\nResolved #{@data.publications_index.keys.count} publications\n"

      end

      def handle_list_of_genera_lepindex
        # BUTMOTH_SPECIESFILE_MASTER.txt (Butterflies & Moths Generic Index)
        #
        # GENUS_NUMBER
        # GENUS_PAGE_COMMENT
        # GENUS_MEMO
        # GENUS_REF
        # TS_REF
        # TS_GENUS
        # TS_SPECIES
        # TS_AUTHOR
        # TS_YEAR
        # TS_PAGE_COMMENT
        # TS_COUNTRY
        # TS_LOCALITY
        # TS_TYPE_STATUS
        # TS_TYPE_DEPOSITORY
        # TS_LECTOTYPE_BY
        # TS_COMMENT
        # TSD_REF
        # TSD_DESIGNATION
        # TSD_COMMENT

        path = @args[:data_directory] + 'BUTMOTH_SPECIESFILE_MASTER.txt'
        print "\nHandling genera\n"
        raise "file #{path} not found" if not File.exists?(path)

        file = CSV.foreach(path, col_sep: "\t", encoding: 'iso-8859-1:UTF-8', headers: true)
        file.each_with_index do |row, i|
          print "\r#{i}"
          @data.genera_index[row['GENUS_NUMBER'].to_i] = row
        end

        puts "\nResolved #{@data.genera_index.keys.count} genera\n"
      end

      def handle_images_lepindex
        # IMAGES.txt (LepIndex)
        # TaxonNo
        # Card_code
        # Path
        # Front_image
        # Back_image

        path = @args[:data_directory] + 'IMAGES.txt'
        print "\nHandling images\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", encoding: 'iso-8859-1:UTF-8', headers: true)
        file.each_with_index do |row, i|
          print "\r#{i}"
          @data.images_index[row['TaxonNo']] = row
        end

        puts "\nResolved #{@data.images_index.keys.count} images\n"
      end

      def handle_species_lepindex
        # VIADOCS.txt
        #
        # TaxonNo
        # SCIENTIFIC_NAME_on_card
        # Original_Author
        # Original_Year
        # Original_Genus
        # OrigSubgen
        # Original_Species
        # Original_Subspecies
        # Original_Infrasubspecies
        # Availability
        # Current_rank_of_name
        # valid_parent_id
        # Current_superfamily
        # Current_family
        # Current_subfamily
        # Current_tribe
        # Current_subtribe
        # Current_genus
        # CurrSubgen
        # Current_species
        # Current_subspecies
        # Current_author
        # Current_year
        # ButmothNo
        # Last_changed_by
        # Date_changed

        path = @args[:data_directory] + 'VIADOCS.txt'
        print "\nHandling species\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", encoding: 'iso-8859-1:UTF-8', headers: true)

        rank_classes = {'GENUS' => Ranks.lookup(:iczn, 'genus'),
                        'SUBGENUS' => Ranks.lookup(:iczn, 'subgenus'),
                        'SPECIES' => Ranks.lookup(:iczn, 'species'),
                        'SUBSPECIES' => Ranks.lookup(:iczn, 'subspecies')}.freeze
        original_ranks = {'Original_Genus' => 'genus',
                          'OrigSubgen' => 'genus',
                          'Original_Species' => 'species',
                          'Original_Subspecies' => 'species',
                          'Original_Infrasubspecies' => 'species'}.freeze
        butmoth_fields = %w{GENUS_MEMO GENUS_REF TS_REF TS_GENUS TS_SPECIES TS_AUTHOR TS_YEAR TS_PAGE_COMMENT TS_COUNTRY TS_LOCALITY TS_TYPE_STATUS TS_TYPE_DEPOSITORY TS_LECTOTYPE_BY TS_COMMENT TSD_REF TSD_DESIGNATION TSD_COMMENT }.freeze

        @invalid_relationships = {}

        data_attribute_fields = %w{TaxonNo Original_Genus OrigSubgen Original_Species Original_Subspecies Original_Infrasubspecies Availability valid_parent_id ButmothNo}.freeze 
        original_combination_fields =  %w{Original_Genus OrigSubgen Original_Species Original_Subspecies Original_Infrasubspecies}.freeze

        @image_index = nil

        begin # ensure file open/closes
          @image_index = File.new( File.join(@args[:data_directory], @data.image_index_filename), 'w')

          #        result = RubyProf.profile do

          ['GENUS', 'SUBGENUS', 'SPECIES', 'SUBSPECIES'].each do |rank|
            GC.start
            print "\n#{rank}\n"

            file.each_with_index do |row, i|
              #if rank == 'GENUS' || i > 0 && i < 1500

              #              break if i == 2000

              #              if i % 2000 == 0
              #                GC.start
              #              end
              #  break if i > 200

              print "\r#{i}"
              if row['Current_rank_of_name'] == rank
                genus, subgenus, species = nil, nil, nil
                superfamily = @data.parent_id_index['superfamily:' + row['Current_superfamily'].to_s]
                family = @data.parent_id_index['family:' + row['Current_family'].to_s]
                subfamily = @data.parent_id_index['subfamily:' + row['Current_subfamily'].to_s]
                tribe = @data.parent_id_index['tribe:' + row['Current_tribe'].to_s]
                subtribe = @data.parent_id_index['subtribe:' + row['Current_tribe'].to_s]
                genus = @data.parent_id_index['genus:' + row['Current_genus'].to_s] if rank != 'GENUS'
                subgenus = @data.parent_id_index['subgenus:' + row['CurrSubgen'].to_s] if rank != 'GENUS' && rank != 'SUBGENUS'
                species = @data.parent_id_index['species:' + row['Current_genus'].to_s + ' ' + row['Current_species'].to_s] if rank != 'GENUS' && rank != 'SUBGENUS'  && rank != 'SPECIES'

                parent_id = @lepidoptera.id

                if superfamily.nil? && !row['Current_superfamily'].blank?
                  superfamily = Protonym.find_or_create_by(name: row['Current_superfamily'], parent_id: parent_id, rank_class: Ranks.lookup(:iczn, 'superfamily'), project_id: $project_id).id
                  @data.parent_id_index['superfamily:' + row['Current_superfamily'].to_s] = superfamily
                end

                parent_id = superfamily unless superfamily.nil?
                if family.nil? && !row['Current_family'].blank?
                  family = Protonym.find_or_create_by(name: row['Current_family'], parent_id: parent_id, rank_class: Ranks.lookup(:iczn, 'family'), project_id: $project_id).id
                  @data.parent_id_index['family:' + row['Current_family'].to_s] = family
                end

                parent_id = family unless family.nil?
                if subfamily.nil? && !row['Current_subfamily'].blank? && row['Current_subfamily'] != 'Subfamily unassigned'
                  if row['Current_subfamily'] =~ / group/
                    subfamily = Protonym.find_or_create_by(name: row['Current_subfamily'].gsub(' group', ''), parent_id: parent_id, rank_class: 'NomenclaturalRank::Iczn::GenusGroup::Supergenus', project_id: $project_id).id
                  else
                    subfamily = Protonym.find_or_create_by(name: row['Current_subfamily'], parent_id: parent_id, rank_class: Ranks.lookup(:iczn, 'subfamily'), project_id: $project_id).id
                  end
                  @data.parent_id_index['subfamily:' + row['Current_subfamily'].to_s] = subfamily
                end

                parent_id = subfamily unless subfamily.nil?
                if tribe.nil? && !row['Current_tribe'].blank? && row['Current_tribe'] != 'Tribe unassigned'
                  tribe = Protonym.find_or_create_by(name: row['Current_tribe'], parent_id: parent_id, rank_class: Ranks.lookup(:iczn, 'tribe'), project_id: $project_id).id
                  @data.parent_id_index['tribe:' + row['Current_tribe'].to_s] = tribe
                end

                parent_id = tribe unless tribe.nil?
                if subtribe.nil? && !row['Current_subtribe'].blank?
                  subtribe = Protonym.find_or_create_by(name: row['Current_subtribe'], parent_id: parent_id, rank_class: Ranks.lookup(:iczn, 'subtribe'), project_id: $project_id).id
                  @data.parent_id_index['subtribe:' + row['Current_subtribe'].to_s] = subtribe
                end

                parent_id = subtribe unless subtribe.nil?
                if genus.nil? && !row['Current_genus'].blank? && rank != 'GENUS' && row['Current_genus'] != 'GENUS UNKNOWN' && row['Current_genus'] != 'ORIGINAL GENUS UNDETERMINED' && row['Current_genus'] !=~ /_AUCTORUM/
                  genus = Protonym.find_or_create_by(name: row['Current_genus'].titleize, parent_id: parent_id, rank_class: Ranks.lookup(:iczn, 'genus'), project_id: $project_id).id
                  @data.parent_id_index['genus:' + row['Current_genus'].to_s] = genus
                end

                parent_id = genus unless genus.nil?
                if subgenus.nil? && !row['CurrSubgen'].blank? && rank != 'GENUS' && rank != 'SUBGENUS'
                  subgenus = Protonym.find_or_create_by(name: row['CurrSubgen'].titleize, parent_id: parent_id, rank_class: Ranks.lookup(:iczn, 'subgenus'), project_id: $project_id).id
                  @data.parent_id_index['subgenus:' + row['CurrSubgen'].to_s] = subgenus
                end

                parent_id = subgenus unless subgenus.nil?
                if species.nil? && !row['Current_species'].blank? && rank != 'GENUS' && rank != 'SUBGENUS'  && rank != 'SPECIES'
                  species = Protonym.find_or_create_by(name: row['Current_species'], parent_id: parent_id, rank_class: Ranks.lookup(:iczn, 'species'), project_id: $project_id).id
                  @data.parent_id_index['species:' + row['Current_genus'].to_s + ' ' + row['Current_species'].to_s] = species
                end

                parent_id = species unless species.nil?
                #byebug if row['Original_Genus'] == 'ACANTHOSPHINX'

                unless row['SCIENTIFIC_NAME_on_card'] == 'GENUS UNKNOWN' || row['SCIENTIFIC_NAME_on_card'] =~ /_AUCTORUM/
                  name = (rank =~ /GENUS/) ? row['SCIENTIFIC_NAME_on_card'].titleize : row['SCIENTIFIC_NAME_on_card']
                  verbatim_name = nil

                  name = name.gsub('x ', '') if name =~/\Ax ./

                  if name =~ /..(-|_| )../
                    verbatim_name = name.gsub('-', ' ').gsub('_', ' ')
                    name = verbatim_name.split(' ').last
                  end

                  year = row['Original_Year'] =~ /\A\d\d\d\d\z/ ? row['Original_Year'] : nil

                  protonym = Protonym.new(name: name,
                                          parent_id: parent_id,
                                          #  source_id: nil,
                                          year_of_publication: year,
                                          verbatim_author: row['Original_Author'],
                                          rank_class: rank_classes[row['Current_rank_of_name']],
                                          verbatim_name: verbatim_name,
                                          project_id: $project_id,
                                          created_by_id: find_or_create_user_lepindex(row['Last_changed_by']),
                                          updated_by_id: $user_id,
                                          created_at: time_from_field(row['Date_changed']),
                                          updated_at: $user_id
                                         )

                  data_attribute_fields.each do |k|
                    protonym.data_attributes.new(import_predicate: k, value: row[k], type: 'ImportAttribute') unless row[k].blank?
                  end

                  protonym.data_attributes.new(import_predicate: 'Original_Year', value: row['Original_Year'], type: 'ImportAttribute') if !row['Original_Year'].blank? && protonym.year_of_publication.blank?
                  protonym.taxon_name_classifications.new(type: @classification_classes['not latin']) if name =~ /\d+-../

                  begin
                    protonym.save!
                  rescue ActiveRecord::RecordInvalid
                    if !protonym.errors.messages[:name].blank?
                      protonym.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin')
                      protonym.save!
                    else
                      puts Rainbow("protonym #{protonym.name} failed to save, skipping to next record.").red
                      puts protonym.errors.messages.to_s
                      next # Everything beyond this point requires a successful save off
                    end
                  end

                  if row['Current_genus'] =~ /(_AUCTORUM|GENUS UNKNOWN)/ && rank =~ /SPECIES/
                    @list_of_relationships << {'taxon' => protonym.id, 'relationship' => 'Incertae sedis', 'valid species' => parent_id}
                  end

                  if row['valid_parent_id'].blank?
                    case rank
                    when 'GENUS'
                      @data.parent_id_index['genus:' + row['SCIENTIFIC_NAME_on_card'].to_s] = protonym.id
                    when 'SUBGENUS'
                      @data.parent_id_index['subgenus:' + row['SCIENTIFIC_NAME_on_card'].to_s] = protonym.id
                    when 'SPECIES'
                      @data.parent_id_index['species:' + row['Current_genus'].to_s + ' ' + row['SCIENTIFIC_NAME_on_card'].to_s] = protonym.id
                    when 'SUBSPECIES'
                      @data.parent_id_index['species:' + row['Current_genus'].to_s + ' ' + row['Current_species'].to_s + ' ' + row['SCIENTIFIC_NAME_on_card'].to_s] = protonym.id
                    end
                  end

                  unless @data.images_index[row['TaxonNo']].nil?
                    %w{Card_code Path Front_image Back_image}.each do |k|
                      protonym.data_attributes.create!(import_predicate: k, value: @data.images_index[row['TaxonNo']][k], type: 'ImportAttribute') unless @data.images_index[row['TaxonNo']][k].blank?
                    end

                    file1 = @data.images_index[row['TaxonNo']]['Front_image'].blank? ? nil : @args[:data_directory] + @data.images_index[row['TaxonNo']]['Path'].gsub('Q:\\', '').gsub('\\', '/').to_s + @data.images_index[row['TaxonNo']]['Front_image'].to_s
                    file2 = @data.images_index[row['TaxonNo']]['Back_image'].blank? ? nil : @args[:data_directory] + @data.images_index[row['TaxonNo']]['Path'].gsub('Q:\\', '').gsub('\\', '/').to_s + @data.images_index[row['TaxonNo']]['Back_image'].to_s

                    @image_index.puts [protonym.id, "\t", file1, "\n"].join if file1
                    @image_index.puts [protonym.id, "\t", file2, "\n"].join if file2
                  end

                  @data.taxonno_index[row['TaxonNo'].to_i.to_s] = protonym.id

                  availability = row['Availability']

                  if @relationship_classes[availability].nil?
                    print "\nInvalid relationship: '#{availability}' #{protonym.name} [row #{i}]\n"
                    @invalid_relationships[availability] ||= 0
                    @invalid_relationships[availability] += 1

                  elsif !row['valid_parent_id'].blank?
                    @list_of_relationships << {'taxon' => protonym.id, 'relationship' => availability, 'valid species' => row['valid_parent_id']}
                  end

                  unless row['ButmothNo'].blank?
                    brow = @data.genera_index[row['ButmothNo'].to_i]

                    if brow.nil?
                      print "\nButmothNo #{row['ButmothNo']} is invalid\n"
                    else
                      butmoth_fields.each do |f|
                        protonym.data_attributes.find_or_create_by(import_predicate: f, value: brow[f], type: 'ImportAttribute', project_id: $project_id) unless brow[f].blank?
                      end
                    end

                    ref = brow.nil? ? nil : @data.citation_to_publication_index[brow['GENUS_REF']]

                    citation = brow.nil? ? nil : @data.citations_index[brow['GENUS_REF']]
                    c = Citation.create!(citation_object: protonym, is_original: true, source_id: ref, pages: citation['PAGE']) unless ref.nil? || citation.nil?

                    @list_of_relationships << {'taxon' => protonym.id, 'relationship' => 'type species', 'type species' => brow['TS_SPECIES'], 'type species reference' => brow['TS_REF'], 'type designation' => brow['TSD_DESIGNATION'], 'ButmothNo' => brow['ButmothNo'].to_i, 'valid genus' => row['valid_parent_id']} unless brow.nil?
                  end

                  unless @classification_classes[availability].nil?
                    TaxonNameClassification.create!(taxon_name_id: protonym.id, type: @classification_classes[availability])
                  end

                  #byebug if row['TaxonNo'] == '48940'

                  original_combination_fields.each do |t|
                    if t == 'Original_Genus' || t == 'OrigSubgen'
                      n = row[t]
                    elsif t == 'Original_Species'
                      n = row['Original_Genus'].to_s + ' ' + row[t].to_s
                    elsif t == 'Original_Subspecies'
                      n = row['Original_Genus'].to_s + ' ' + row['Original_Species'].to_s + ' ' + row[t].to_s
                    end
                    @list_of_relationships << {'taxon' => protonym.id, 'relationship' => t, 'original' => n} unless row[t].blank?
                  end

                end
              end
            end
          end

        ensure
          @image_index.close
        end
        #        end # End RubyProf

        #        printer = RubyProf::GraphHtmlPrinter.new(result)
        #        printer.print(STDOUT, {})

        puts Rainbow('All invalid (unrecognized) relationships:').red 
        ap Rainbow(@invalid_relationships).red


        print "\nAdding relationships\n"
        @list_of_relationships.each_with_index do |r, i|
          print "\r#{i}"
          tr = nil
          if @relationship_classes[r['relationship']] =~ /TaxonNameRelationship::OriginalCombination/
            origr = original_ranks[r['relationship']]
            if origr == 'genus'
              stn = @data.parent_id_index['genus:' + r['original'].to_s]
              stn = @data.parent_id_index['subgenus:' + r['original'].to_s] if stn.nil?
              if stn.nil?  && r['original'] != 'ORIGINAL GENUS UNDETERMINED'
                stn = Protonym.find_or_create_by(name: r['original'].titleize, rank_class: Ranks.lookup(:iczn, 'genus'), project_id: $project_id)
                if stn.parent_id.nil?
                  stn.parent_id = @lepidoptera.id
                  stn.save
                end
                stn = stn.id
                @data.parent_id_index['genus:' + r['Current_genus'].to_s] = stn
              end
            elsif origr == 'species'
              stn = @data.parent_id_index['species:' + r['original'].to_s]
              stn = @data.parent_id_index['subspecies:' + r['original'].to_s] if stn.nil?
            end
            unless stn.nil?
              tr = TaxonNameRelationship.new(subject_taxon_name_id: stn,
                                             object_taxon_name_id: r['taxon'],
                                             type: @relationship_classes[r['relationship']]
                                            )
            end
          elsif r['relationship'] == 'Incertae sedis'
            tr = TaxonNameRelationship.new(subject_taxon_name_id: r['taxon'],
                                           object_taxon_name_id: r['valid species'],
                                           type: @relationship_classes[r['relationship']]
                                          )
          elsif !r['valid species'].nil?
            valid_species = @data.taxonno_index[r['valid species'].to_i.to_s]
            if valid_species.nil?
              print "\nInvalid valid_parent_id: #{r['valid species']}\n"
            else
              relationship = @relationship_classes[r['relationship']]
              relationship = 'TaxonNameRelationship::Iczn::Invalidating' if relationship == ''
              tr = TaxonNameRelationship.new(subject_taxon_name_id: r['taxon'],
                                             object_taxon_name_id: valid_species,
                                             type: relationship
                                            )
            end
          elsif !r['type species'].blank?
            if @relationship_classes[r['type designation']].nil?
              relationship = @relationship_classes['type species']
            else
              relationship = @relationship_classes[r['type designation']]
            end
            children = []
            children = Protonym.descendants_of(Protonym.find(r['taxon']).get_valid_taxon_name) if Protonym.find(r['taxon']).get_valid_taxon_name
            children = children + Protonym.descendants_of(Protonym.find(r['taxon']))
            unless children.empty?
              children = children.select{|c| c.name == r['type species']}

              unless children.empty?
                tr = TaxonNameRelationship.new(subject_taxon_name_id: children.first.id,
                                               object_taxon_name_id: r['taxon'],
                                               type: relationship
                                              )

                ref = @data.citation_to_publication_index[r['type species reference']]
                citation = @data.citations_index[r['type species reference']]
                print "\nTS_REF #{r['type species reference']} is invalid\n" if citation.nil?

                # TODO: !! FIX
                #        children.first.source_id = ref unless ref.nil?
                Citation.create(citation_object: children.first, is_original: true, source_id: ref, pages: citation['PAGE']) unless ref.nil? || citation.nil?

                children.first.save
              end
            end
          end

          if tr.nil?
            true
          else
            begin
              tr.save!
            rescue ActiveRecord::RecordInvalid
              puts Rainbow(tr.errors.messages.to_s).red
            end
          end
        end

      end

      def soft_validations_lepindex
        fixed = 0
        print "\nApply soft validation fixes to taxa 1st pass \n"
        i = 0
        TaxonName.where(project_id: $project_id).find_each do |t|
          i += 1
          print "\r#{i}    Fixes applied: #{fixed}"
          t.soft_validate
          t.fix_soft_validations
          t.soft_validations.soft_validations.each do |f|
            fixed += 1  if f.fixed?
          end
        end
        print "\nApply soft validation fixes to relationships \n"
        i = 0
        TaxonNameRelationship.where(project_id: $project_id).find_each do |t|
          i += 1
          print "\r#{i}    Fixes applied: #{fixed}"
          t.soft_validate
          t.fix_soft_validations
          t.soft_validations.soft_validations.each do |f|
            fixed += 1  if f.fixed?
          end
        end
        print "\nApply soft validation fixes to taxa 2nd pass \n"
        i = 0
        TaxonName.where(project_id: $project_id).find_each do |t|
          i += 1
          print "\r#{i}    Fixes applied: #{fixed}"
          t.soft_validate
          t.fix_soft_validations
          t.soft_validations.soft_validations.each do |f|
            fixed += 1  if f.fixed?
          end
        end
      end

      def find_or_create_user_lepindex(name)
        if name.blank?
          $user_id
        elsif @data.user_index[name]
          @data.user_index[name].id
        else
          email = name.split(' ').last.downcase + '@unavailable.email.net'

          user_name = name

          existing_user = User.where(email: email.downcase)

          if existing_user.empty?
            pwd = rand(36**10).to_s(36)
            user = User.create(email: email, password: pwd, password_confirmation: pwd, name: user_name,
                               tags_attributes:   [ { keyword: @lepindex_imported } ]
                              )
          else
            user = existing_user.first
          end

          @data.user_index[name] = user
          user.id
        end
      end
    end
  end
end



