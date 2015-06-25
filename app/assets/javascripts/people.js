//function exists(string) {
//    if (string != undefined && string != "") {
//        return true;}
//    else
//        {
//            return false;
//        }
//    }

function bind_hover() {
    // bind a hover event to an ellipsis
    hiConfig = {
        sensitivity: 3, // number = sensitivity threshold (must be 1 or higher)
        interval: 400, // number = milliseconds for onMouseOver polling interval
        timeout: 200, // number = milliseconds delay before onMouseOut
        over: function() { alert('hi'); }, // function = onMouseOver callback (REQUIRED)
        out: function() { alert('bye');  } // function = onMouseOut callback (REQUIRED)
    };
    $('.hoverme').hoverIntent(hiConfig);
}

function get_first_name(string) {
    // split on (white) space
    //return string.split(" ", 2)[0];
  // split on (white) space or commma
  var delimiter;
  if(string.indexOf(",") > 1) {delimiter = ","}
  if(string.indexOf(", ") > 1) {delimiter = ", "}
  if(string.indexOf(" ") > 1 && delimiter != ", ") {delimiter = " "}
   return string.split(delimiter, 2)[0];
}

function get_last_name(string) {
    // split on (white) space or commma
  var delimiter;
  if(string.indexOf(",") > 1) {delimiter = ","}
  if(string.indexOf(", ") > 1) {delimiter = ", "}
  if(string.indexOf(" ") > 1 && delimiter != ", ") {delimiter = " "}

  return string.split(delimiter, 2)[1];
}

// first_name and last_name must be strings
function get_full_name(first_name, last_name) {
    var separator = "";
    if (!!last_name && !!first_name) {
        //alert("both have values");
        separator = ", ";
    }
    return (last_name + separator + first_name);
    //return ($.grep([last_name, separator, first_name], Boolean).join());
}

function clear_role_picker(target) {
    // empties search text box and hides new_person div

    var role_picker;
    role_picker = $(target).closest("#role_picker").find("#autocomplete");
    $(role_picker).val("");
    //$("#autocomplete").val("");
    //$("#autocomplete").text("");
    $('#new_person').attr("hidden", true);
}

var _initialize_role_picker_widget;

_initialize_role_picker_widget = function
    init_role_picker() {

    $("#add_new").click(function () {
        $("#role_list").append(
            $('<li>').append(
                $("#name_label").text()
            )
        );
        // unset form fields
        // hide the form field
        $('#new_person').attr("hidden", true);
        // unset autocomplete input box
        clear_role_picker(this);
    });

    $("#autocomplete").autocomplete({
        source: '/people/lookup_person',
        open: function( event, ui ) {
            bind_hover(); //alert('open');
        },
        select: function (event, ui) {
            // execute on select event in search text box

            // add name to list
            $("#role_list").append($('<li>').append(ui.item.value));
            // clear search form
            clear_role_picker(this);
            return false;
        }
    }).autocomplete( "instance" )._renderItem = function( ul, item ) {
        return $( "<li>" )
            .append( "<a>" + item.label + " <span class='hoverme'>...</span> " + "</a>" )
            .appendTo( ul );
    };

    $("#autocomplete").keyup(function () {
        // copies search textbox content to new_person name_label
        var input_term = $("#autocomplete").val();
        var last_name = get_last_name(input_term);
        var first_name = get_first_name(input_term);

        if (input_term.length == 0) {
            //alert('hello');
            $('#new_person').attr("hidden", true);
        }
        else {
            $('#new_person').removeAttr("hidden");
        }
      if(input_term.indexOf(",") > 1) {   //last name, first name format
        var swap = first_name;
        first_name = last_name;
        last_name = swap;
      }

      $("#person_first_name").val(first_name).change();
        $("#person_last_name").val(last_name).change();
    });

    $("#switch").click(function () {
        // switch the values in the first & last names
        var tmp = $("#person_first_name").val();
        $("#person_first_name").val($("#person_last_name").val()).change();
        $("#person_last_name").val(tmp).change();
    });

    $("#expand").click(function () {
        // alternately hides and displays person_form
        $("#person_form").toggle();
    });

    $("#person_form input").on("change keyup", function () {
        // update mirrored label
        $("#name_label").html(get_full_name($("#person_first_name").val(), $("#person_last_name").val()));
        // build full name out of individual labels
    });

};

$(document).ready(_initialize_role_picker_widget);
$(document).on("page:load", _initialize_role_picker_widget);
