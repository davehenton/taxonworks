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
        select: function select_auto() {
          var selected_name = select_auto.arguments[1].item.label;
          var selected_id = select_auto.arguments[1].item.id;
          $(this.parentNode.parentNode.children[1])
            .find('#taxon_name_id_for_otu_match_form_hidden_value').val(selected_id.toString());
          // var span_id = $(this).parent().parent().children('td').children('span')[0].id;
          var span_id = $(this).parent().children('span')[0].id;
          /*
           This function (below) is used in leiu of the fuzzy search from the controller (since it is undefined)
           to populate and exercize the radio button selection of taxon names
           */
          TW.views.tasks.otus.otu_to_taxon_name.insertOrAppendRBL($('#' + span_id), selected_name, selected_id);
        }
      });
    });

    $(":submit").click(function (event) {
      var hidden_taxon_name_id = $(this.parentNode.children['otu[taxon_name_id]']);
      var chkbox_select = $(this.parentNode.children).find('fieldset');
      if (chkbox_select) {                            // if there is a radio button list
        var taxon_name_id = chkbox_select.serialize().split('=')[1];  // try for a taxon_name_id
        if (taxon_name_id) {                          // if there is a taxon_name_id
          hidden_taxon_name_id.val(taxon_name_id);    // replace hidden value from autocomplete if radio button selected
        }
      }                    // else leave the autocomplete value
      this.disabled = true;   // use this diectly instead of
    })                                                // and also perform default submit

  },

  insertOrAppendRBL: function (span_selector, name, taxon_name_id) {
    if (!(span_selector.children('fieldset')[0])) {
      span_selector.append('<fieldset name="otu[]"></fieldset>');        // .tagName) != 'FIELDSET'
    }
    span_selector.children('fieldset')
      .append('<input type="radio" value="' + taxon_name_id + '" name="taxon_name_id" /> ' + name + '<br>');
  }

});     // end of Object.assign

$(document).ready(function () {
  if ($("#otu_to_taxon_name_index").length) {
    TW.views.tasks.otus.otu_to_taxon_name.init();
  }
});