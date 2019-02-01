let chonsenConfigs = {
  'chosen-select'           : {},
  'chosen-select-max4'       : { max_selected_options : 4},
  'chosen-select-deselect'  : { allow_single_deselect: true },
  'chosen-select-no-single' : { disable_search_threshold: 10 },
  'chosen-select-no-results': { no_results_text: 'Oops, nothing found!' },
  'chosen-select-rtl'       : { rtl: true },
  'chosen-select-width'     : { width: '95%' }
}

function chosen_init_all() {
    for (let selector in chonsenConfigs) {
        $("."+selector).chosen(chonsenConfigs[selector]);
    }
}

function chosen_init(id, className) {
    let target = $("#"+id)
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