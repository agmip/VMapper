let chonsenConfigs = {
  'chosen-select'           : {},
  'chosen-select-max4'       : { max_selected_options : 4, search_contains: true},
  'chosen-select-deselect'  : { allow_single_deselect: true, search_contains: true },
  'chosen-select-deselect-single'  : { allow_single_deselect: true, max_selected_options : 1, search_contains: true },
  'chosen-select-no-single' : { disable_search_threshold: 10 },
  'chosen-select-no-results': { no_results_text: 'Oops, nothing found!' },
  'chosen-select-rtl'       : { rtl: true },
  'chosen-select-width'     : { width: '95%' }
};

function chosen_init_all() {
    for (let selector in chonsenConfigs) {
        $("."+selector).chosen("destroy");
        $("."+selector).chosen(chonsenConfigs[selector]);
    }
}

function chosen_init(id, className) {
    let target = $("#"+id);
    target.chosen("destroy");
    if (className === undefined) {
        for (let selector in chonsenConfigs) {
            if (target.hasClass(selector)) {
                target.chosen(chonsenConfigs[selector]);
                return;
            }
        }
        target.chosen(chonsenConfigs["chosen-select"]);
    } else {
        target.chosen(chonsenConfigs[className]);
    }
}

function chosen_init_name(name, className) {
    let target = $("[name="+name+"]");
    target.chosen("destroy");
    if (className === undefined) {
        for (let selector in chonsenConfigs) {
            if (target.hasClass(selector)) {
                target.chosen(chonsenConfigs[selector]);
                return;
            }
        }
        target.chosen(chonsenConfigs["chosen-select"]);
    } else {
        target.chosen(chonsenConfigs[className]);
    }
}

function chosen_init_name(target, className) {
    target.chosen("destroy");
    if (className === undefined) {
        for (let selector in chonsenConfigs) {
            if (target.hasClass(selector)) {
                target.chosen(chonsenConfigs[selector]);
                return;
            }
        }
        target.chosen(chonsenConfigs["chosen-select"]);
    } else {
        target.chosen(chonsenConfigs[className]);
    }
}