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
    $('.update_otu').click(function (event) {
      event.preventDefault();
      var this_otu = 'otu_id=' + $(this.parentNode.parentNode.children[0]).find('a').attr('otu_id');
      var auto_select_id = $(this.parentNode.parentNode.children[1]).find('#taxon_name_id_for_otu_match_form_hidden_value');
      var chkbox_select = $(this.parentNode.parentNode.children[2]).find('fieldset');
      var query_string = this_otu + '&' + auto_select_id.serialize();
      if (chkbox_select) {
        query_string += '&' + chkbox_select.serialize();
      }
      $.post('update', query_string, function (data) {
        $('#otu_' + data.otu_id).parent('td').parent('tr').find('td')[3].children[0].disabled = true;
      });
    });

    $("[value='Update Otu']").click(function (event) {
      var hidden_taxon_name_id = $(this.parentNode.children['otu[taxon_name_id]']);
      var chkbox_select = $(this.parentNode.children).find('fieldset');
      if (chkbox_select) {
        var taxon_name_id = chkbox_select.serialize().split('=')[1];
        if (taxon_name_id) {
          hidden_taxon_name_id.val(taxon_name_id);
        }
      }
    })
  },

  insertOrAppendRBL: function (span_selector, name, taxon_name_id) {
    if (!(span_selector.children('fieldset')[0])) {
      span_selector.append('<fieldset></fieldset>');        // .tagName) != 'FIELDSET'
    }
    span_selector.children('fieldset')
      .append('<input type="radio" value="' + taxon_name_id + '" name=taxon_name_id" /> ' + name + '<br>');
  }

});     // end of Object.assign

$(document).ready(function () {
  if ($("#otu_to_taxon_name_index").length) {
    TW.views.tasks.otus.otu_to_taxon_name.init();
  }
});