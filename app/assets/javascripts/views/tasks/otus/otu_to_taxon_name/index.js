var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.otus = TW.views.tasks.otus || {};
TW.views.tasks.otus.otu_to_taxon_name = TW.views.tasks.otus.otu_to_taxon_name || {};

Object.assign(TW.views.tasks.otus.otu_to_taxon_name, {

  init: function () {
    // var whereIgo = '/tasks/collecting_events/parse/stepwise/lat_long/';
    var route = location.pathname.replace('index', '');

    var start_next = 0;
    // TW.views.tasks.otus.otu_to_taxon_name.bind_radio_buttons();
    $('.mx-autocomplete').each(function (event) {
      $('.mx-autocomplete', 0).autocomplete({    // on selection, construct or append to checkbox list in <span>
        select: function () {
          var selected_name = 'PlaceholderName';
          var span_id = $(this).parent().parent().children('td').children('span')[0].id;
          // $('#' + span_id).html(span_id);
          TW.views.tasks.otus.otu_to_taxon_name.insertOrAppendRBL($('#' + span_id), selected_name, span_id);
        }
      });
    });

    // $('#skip').click(function (event) {
    //   event.preventDefault();
    //   location.href = route + 'skip?' + $('#lat_long_convert_form').serialize();
    // });
    //
    // $('#re_eval').click(function (event) {
    //   event.preventDefault();
    //   location.href = route + 're_eval?' + $('#lat_long_convert_form').serialize();
    // });
    //
    // $('#save_selected').click(function (event) {
    //   event.preventDefault();
    //   location.href = route + 'save_selected?' + $('#lat_long_convert_form').serialize();
    // });

    //  $('#lat_long_update_record').click(function (event) {
    // put the this id into the form before serializatiun
    // $('#collecting_event_id').val($('this_collecting_event').text());
    //   $.post('update', $("#lat_long_convert_form").serialize() + "&" + $("#gen_georef_box").serialize());
    //  })
  },

  insertOrAppendRBL: function (span_selector, name, taxon_name_id) {
    if (!(span_selector.children('fieldset')[0])) {
      span_selector.append('<fieldset></fieldset>');        // .tagName) != 'FIELDSET'
    }
    span_selector.children('fieldset')
      .append('<input type="radio" value="' + name + '" name="' + taxon_name_id + '" /> ' + name + '<br>');
  }
  //
  // bind_sequence_buttons: function () {
  //   var sel_all = $('#select_all');
  //   var des_all = $('#deselect_all');
  //   var sav_sel = $('#save_selected');
  //   var selectable = $('.selectable_select'); // al array
  //
  //   sel_all.removeAttr('disabled');
  //   sel_all.click(function (event) {
  //     // find all the checkboxes in the 'matching_span' and set them to 'checked'
  //     // class is selectable_select
  //     for (var i = 0; i < selectable.length; i++) {
  //       selectable[i]['checked'] = true;
  //     }
  //     event.preventDefault();
  //   });
  //   des_all.removeAttr('disabled');
  //   des_all.click(function (event) {
  //     // find all the checkboxes in the 'matching_span' and set them to 'checked'
  //     // class is selectable_select
  //     for (var i = 0; i < selectable.length; i++) {
  //       selectable[i]['checked'] = false;
  //     }
  //     event.preventDefault();
  //   });
  //   sav_sel.removeAttr('disabled');
  //   sav_sel.click(function (event) {
  //     // don't know exactly what we need to do here
  //   });
  // },
  //
  // bind_radio_buttons: function () {
  //   $('.select_lat_long').click(function () {
  //     // selector not working
  //     var long = $(this).parent().parent('.extract_row').children('.longitude_value').text();
  //     var lat = $(this).parent().parent('.extract_row').children('.latitude_value').text();
  //     var piece = $(this).parent().parent('.extract_row').children('.piece_value').text();
  //     var params = '';
  //     var checck = $('#include_values').serialize();
  //     $('#verbatim_latitude').val(lat);
  //     $('#verbatim_longitude').val(long);
  //     $('#dd_latitude').val('');
  //     $('#dd_longitude').val('');
  //     params += 'piece=' + encodeURIComponent(piece) /* piece.replace(/ /g, '%20') */;
  //     params += '&lat=' + encodeURIComponent(lat) /* lat.replace(/ /g, '%20') */;
  //     params += '&long=' + encodeURIComponent(long) /* long.replace(/ /g, '%20') */;
  //     params += '&collecting_event_id=' + $('#collecting_event_id').val();
  //     if (checck.length) {
  //       params += '&' + checck;
  //     }
  //     $.get('similar_labels', params, function (local_data) {
  //       $("#match_count").text(local_data.count);
  //       $("#matching_span").html(local_data.table);
  //       $("#matched_latitude").val(lat);
  //       $("#matched_longitude").val(long);
  //       $("#match_gen_georeference").val($("#generate_georeference").serialize());
  //       TW.views.tasks.otus.otu_to_taxon_name.bind_sequence_buttons();
  //     });
  //   });
  // }

});

$(document).ready(function () {
  if ($("#otu_to_taxon_name_index").length) {
    //  var _init_lat_long_parse = TW.views.tasks.collecting_events.parse;
    // _init_lat_long_parse.init();
    TW.views.tasks.otus.otu_to_taxon_name.init();
  }
});

//
// $(document).ready(function () {
//   if ($("#otu_to_taxon_name_index").length) {
//     //  var _init_lat_long_otu_to_taxon_name = TW.views.tasks.otus.otu_to_taxon_name;
//     // _init_lat_long_otu_to_taxon_name.init();
//     TW.views.tasks.otus.otu_to_taxon_name.init();
//   }
// });
