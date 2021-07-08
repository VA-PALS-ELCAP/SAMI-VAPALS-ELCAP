/**
 * VAPALS-ELCAP Global helper functions.
 * @link https://github.com/OSEHRA/VA-PALS
 * @author Domenic DiNatale <domenic.dinatale@paraxialtech.com>
 * @license [Apache-2.0]{@link https://www.apache.org/licenses/LICENSE-2.0.html}
 * @copyright 2018 [VAPALS-ELCAP]{@link http://va-pals.org/}
 * @class
 */

function numericHandlerKeydown(e) {
    //console.log("numericHandlerKeydown() k:" + e.keyCode + " s:" + e.shiftKey + " m:" + e.metaKey + " c:" + e.ctrlKey)
    // Allow: backspace, delete, tab, escape, enter, . (decimal {110 and 190}) (add 173 for - key)
    if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190]) !== -1 ||
        // Allow: Ctrl+A,C,V,X
        ($.inArray(e.keyCode, [65, 67, 86, 88]) !== -1 && (e.ctrlKey === true || e.metaKey === true)) ||
        // Allow: home, end, left, right
        (e.keyCode >= 35 && e.keyCode <= 39)) {
        // let it happen, don't do anything
        return;
    }
    // Ensure that it is a number and stop the keypress
    if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
        e.preventDefault();
    }
}

function wholeNumberHandlerKeydown(e) {
    console.log("wholeNumberHandlerKeydown() k:" + e.keyCode + " s:" + e.shiftKey + " m:" + e.metaKey + " c:" + e.ctrlKey)
    // Allow: backspace, delete, tab, escape, enter, (add 173 for - key)
    if ($.inArray(e.keyCode, [46, 8, 9, 27, 13]) !== -1 ||
        // Allow: Ctrl+A,C,V,X
        ($.inArray(e.keyCode, [65, 67, 86, 88]) !== -1 && (e.ctrlKey === true || e.metaKey === true)) ||
        // Allow: home, end, left, right
        (e.keyCode >= 35 && e.keyCode <= 39)) {
        // let it happen, don't do anything
        return;
    }
    // Ensure that it is a number and stop the keypress
    if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
        e.preventDefault();
    }
}


/**
 * Helper function that revalidates a date when it has changed by manual change or via the datepicker plugin
 * @param e
 * @returns {boolean}
 */
function validateDatePickerOnChange(e) {
    var $datePicker = $(e.target);
    var fv = $datePicker.closest(".validated").data("formValidation");
    var $datePickerInput = $datePicker.find("input").addBack("input");
    if (fv && $datePickerInput.is(":enabled")) {
        const id = $datePickerInput.attr('id');
        if (fv.fields[id]) {
            fv.revalidateField(id);
        }
        $datePickerInput.trigger('keyup');
    }
    return true;
}

/*
    Sets up a checkbox with the given name to behave as an "exclusive" selection, that is:
    - Only one of the checkboxes that have this name can be selected at a time
    - The selected checkbox can be unchecked.

    To a large extent the behavior of an exclusive checkbox is similar to that of a
    radio button; however, the difference is that in a radio button, at least one of the radios
    is selected, where for an exclusive checkbox, all checkboxes could be unselected

    @param checkboxName the 'name' attribute of the checkbox input element
*/
function exclusiveCheckbox(elemSelector, commonParentSelector) {
    $(elemSelector).on("click", function () {
        const thisId = $(this).attr("id");
        const thisName = $(this).attr("name");
        if (this.checked) {
            $(this).closest(commonParentSelector).find('input[name="' + thisName + '"]:checked').filter(
                function (idx, elem) {
                    return $(elem).attr("id") != thisId
                }
            ).prop('checked', false);
        }
    });
}

function uncheckableRadio(elemSelector, commonParentSelector) {
    // when you click a radio, it always is checked, so we need to store its state somewhere else
    $(elemSelector).each(function () {
        const radio = $(this);
        radio.data('checked', radio.prop("checked"));

        radio.on("click", function () {
            const rd = $(this);
            const thisName = $(this).attr("name");
            if (rd.data("checked")) {
                // we need to uncheck it
                rd.prop("checked", false);
                rd.data("checked", false);
                rd.trigger('change');
            } else {
                rd.data('checked', true);
                rd.closest(commonParentSelector).find('[name="' + thisName + '"]').not(rd).data('checked', false);
                rd.trigger('change');
            }
        });

    });
}

function notDash(fvInput) {
    return fvInput.value !== '-';
}

//global application handlers
$(function () {
    $("body").on('keydown', 'input.numeric', numericHandlerKeydown);
    $("body").on('keydown', 'input.whole-number', wholeNumberHandlerKeydown);

    $.each($(".datepicker"), function (i, el) {
        var $input = $(el).find("input").addBack("input"); //find the actual input control
        var restriction = $input.data("restriction");
        var maxDate = restriction === "past" ? moment().endOf('day') : false; //false == no value
        var minDate = restriction === "future" ? moment().startOf('day') : false; //false == no value
        $(el).datetimepicker({
            format: 'MM/DD/YYYY',
            useCurrent: false,
            keepInvalid: true,
            minDate: minDate,
            maxDate: maxDate
        }).on("dp.change", validateDatePickerOnChange);
    });

    $.each($(".yearpicker"), function (i, el) {
        $(el).datetimepicker({
            format: 'YYYY',
            maxDate: moment().add(1, 'h'), //hack to not select today
            minDate: moment().subtract(100, 'y')
        }).on("dp.change", validateDatePickerOnChange);
    });

    //Globally enabled popovers for things like help text.
    $('[data-toggle="popover"]').popover();

    $("#save-for-later-button").on('click', function () {
        $("input[name=samistatus]").val("incomplete");
    });

    $("#submit-button").on('click', function () {
        $("input[name=samistatus]").val("complete");
    });

    /** Handling of the delete form modal */
    $("#delete-form").on("click", function (e) {
        $('#delete-confirm-modal').modal('show');
        e.preventDefault();
        e.stopPropagation();
    });

    $('#delete-form-cancel').on("click", function (e) {
        e.preventDefault();
        e.stopPropagation();

        $('#delete-confirm-modal').modal('hide');
    });

    $('#delete-confirm-modal').keypress(function (e) {
        var c = String.fromCharCode(e.which);
        if (e.which == 13 /* key code for Enter */ || c === "y" || c === "Y") {
            $("#delete-form-btn").trigger("click");
        } else if (c === "n" || c === "N") {
            $('#delete-form-cancel').trigger("click");
        }
    });
    /* ---------------- delete form modal dialog end ------*/

    /**
     * Attach an onclick handler to "a.navigation" elements such that when clicked, submits a form POST or GET using
     * parameters in the elements <code>data-*</code> attributes.
     *
     * Note that the <code>studyid</code> and <code>site</code> parameters are always injected based on localStorage
     */
    $("a.navigation").on("click", function () {
        const data = $(this).data();
        const method = data.method === undefined ? "GET" : data.method;
        delete data.method;

        //field names are case-sensitive when POSTing to the backend. Generally lowercase is preferred.
        data.studyid = localStorage.getItem("studyid");
        data.site = localStorage.getItem("siteid");

        const form = document.createElement('form');
        form.style.visibility = 'hidden'; // no user interaction is necessary
        form.method = method; //'POST'; // forms by default use GET query strings
        form.action = method.toLowerCase() === "get" ? $(this).attr("href") : "/vapals";

        for (key in data) {
            const input = document.createElement('input');
            input.name = key;
            input.value = data[key];
            form.appendChild(input); // add key/value pair to form
        }
        document.body.appendChild(form);
        form.submit();

        return false;
    });

    $("input[type=text].decimalformat").on("blur", function (e) {
        const textField = e.target;

        const fieldVal = $(textField).val();

        if (fieldVal) {
            textField.value = Number(fieldVal).toFixed(1);
        }
    }).first().trigger('blur');

    //handle collapsible controls by toggling chevron icon and applying value to hidden field
    $(".collapse").on('show.bs.collapse', function () {
        const id = $(this).attr('id');
        const $controller = $("[aria-controls=" + id + "]");
        $controller.find(".fa-chevron-down").hide();
        $controller.find(".fa-chevron-up").show();
        const fieldName = $controller.data("field-name");
        $("[name=" + fieldName + "]").val("y");
    }).on('hide.bs.collapse', function () {
        const id = $(this).attr('id');
        const $controller = $("[aria-controls=" + id + "]");
        $controller.find(".fa-chevron-down").show();
        $controller.find(".fa-chevron-up").hide();
        const fieldName = $controller.data("field-name");
        $("[name=" + fieldName + "]").val("");
    });

    //open panels where the field name is already set to "y"
    $.each($(".panel-heading[data-toggle=collapse]"), function (i, controller) {
        const $controller = $(controller);
        const href = $controller.attr('href');
        const fieldName = $controller.data('field-name');
        const fieldValue = $("[name=" + fieldName + "]").val();
        if (fieldValue === "y") {
            $(href).collapse('show');
        }
    });
});
