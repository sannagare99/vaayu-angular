$(function () {
    'use strict';
    updateBadgeCount();
    /**
     * Adds new table info
     */
    $('.provisioning .add-new-item').on('click', function () {
        var modalType = $('.provisioning .nav-tabs .active a').data('modal-type');
        if (!modalType) {
            showEditContentArea();
            showEditActions();
        }
    });

    /**
     * Show table edit zone on click "Edit" action
     */
    $(document).on('click', '.table-no-modal .edit', function () {
        showEditActions();
        showEditContentArea();
    });

    /**
     *  Set "add new" button active class depend on active tab
     */
    $('.provisioning .nav-tabs a').on('show.bs.tab', function (e) {
        var currentTab = $(this).text();
        var defaultAddClass = "editor_create add-new-item btn btn-sm btn-primary btn-fixed-width";
        var $nextTabWrap = $(e.target).closest('li');
        var $prevTabWrap = $(e.relatedTarget).closest('li');
        var $addItemButton = $('.nav-actions .add-new-item');
        var source = $(e.target).data('source');
        var modalType = $(e.target).data('modal-type');
        var submitBtn = $('.nav-actions .submit-btn');
        $(".provisioning .edit-buttons .submit-btn").fadeIn()
        $(".provisioning .edit-buttons").fadeOut()

        // change modal target
        var tabHash = $(e.target).attr('href').substring(1);
        $addItemButton
            .attr('data-target', '#modal-' + tabHash);

        $('.provisioning .edit-buttons').hide();
        // Display add button
        if(currentTab.toLowerCase() != "general settings" && currentTab.toLowerCase() != 'system settings' && currentTab.toLowerCase() != 'compliances') { 
            if (!$addItemButton.is(":visible")) {
                $('.provisioning .action-buttons').fadeIn(200);
                $addItemButton.show();
            }
        }

        // set active class for tab
        $addItemButton.attr('class', defaultAddClass);
        $addItemButton
            .removeClass($prevTabWrap.attr('class'))
            .addClass($nextTabWrap.attr('class'));
        submitBtn.removeClass (function (index, className) { return (className.match (/\bform-\S+/g) || []).join(' ');});
        submitBtn.addClass('form-' + $nextTabWrap.attr('class'));

        // change data attr depend on tab type
        switch (modalType) {
            case 'simple':
                $addItemButton
                    .attr('data-toggle', 'modal')
                    .attr('data-remote', '')
                    .attr('href', '');
                break;
            case 'remote':
                $addItemButton
                    .attr('data-toggle', '')
                    .attr('data-remote', 'true')
                    .attr('href', source);
                break;
            default:
                $addItemButton
                    .attr('data-toggle', '')
                    .attr('data-remote', 'true')
                    .attr('href', source);
                submitBtn.attr('form', 'form-' + $nextTabWrap.attr('class'));
        }

        restoreDefaultTabState(currentTab);

    });

    /**
     * Edit table info
     */
    $('.provisioning .edit-buttons, #employees, #drivers, #vehicles').on('click', 'a.cancel', function (e) {
        e.preventDefault();

        var action = $(this).data('action');

        if (action == 'cancel') {
            restoreDefaultTabState();
        }
    });

    $(".resource-headers a").on("click", function(){
        $(".resource-headers a.active").removeClass("active");
        $('.provisioning .action-buttons .ingest').addClass('hide', 200);
        $.each($(".nav-tabs li.active"), function(i, e) { $(e).removeClass("active") });
        switch ($(this).attr("href")) {
            case '#places':
                if($(".places ul li a").size() > 1) {
                    showPlaces();
                    $(".places ul li a")[1].click();
                } else {
                    showDefaultResource()
                }
                break;
            case '#things':
                if($(".things ul li a").size() > 1) {
                    showThings();
                    $(".things ul li a")[1].click();
                } else {
                    showDefaultResource()
                }
                break;
            default:
                showDefaultResource()
        }
    });
});

/**
 * Show Edit Actions block
 */
function showEditActions() {
    $('.provisioning .action-buttons').fadeOut(200, function () {
        $('.provisioning .edit-buttons').fadeIn(200);
    });
}

/**
 * Hide Edit Actions block
 */
function hideEditActions() {
    $('.provisioning .edit-buttons').fadeOut(200, function () {
        $('.provisioning .action-buttons').fadeIn(200);
    })
}

/**
 * Show Edit Content Area
 */
function showEditContentArea() {
    var $activePane = $('.provisioning .tab-pane.active');

    $activePane.find('.table-wrap').fadeOut(200, function () {
        $activePane.find('.table-content-edit').fadeIn(200);
    });
}

/**
 * Hide Edit Content Area
 */
function hideEditContentArea() {
    var $activePane = $('.provisioning .tab-pane.active');

    $activePane.find('.table-content-edit').fadeOut(200, function () {
        $activePane.find('.table-wrap').fadeIn(200);
    })
}

function hideSaveButton() {
    $('.provisioning .save-button').fadeOut(200);
}


/**
 * Restore default tab state
 */
function restoreDefaultTabState(currentTab="") {
    switch(currentTab.toLowerCase()){
        case 'compliances':
            $('.provisioning .save-button').hide()
            $('.provisioning .action-buttons').show()        
            break;
        case 'general settings':
            hideEditActions();
            hideEditContentArea();
            $('.provisioning .action-buttons').hide()
            $('.provisioning .save-button').fadeIn(200);
            break;
        case 'system settings':
            hideEditActions();
            hideEditContentArea();
            $('.provisioning .action-buttons').hide()
            $('.provisioning .save-button').fadeIn(200);
            break;
        default:
            hideEditActions();
            hideEditContentArea();
    }
}

/**
 * Set active state for first tab and "Add new" button on page load.
 */
function setTabActiveState() {

    var $addButton = $('.add-new-item');
    var submitBtn = $('.nav-actions .submit-btn');

    var $activeTab = $('.provisioning .nav-tabs li.active');

    var source = $activeTab.find('a').data('source');
    var isModal = $activeTab.find('a').data('modalType');
    var tabClassesStr = $activeTab.attr('class');
    var activeTabClass = tabClassesStr.slice(0, tabClassesStr.indexOf(' active'));
    enableCurrentTab($('.provisioning .nav-tabs li.active a').attr("href"));

    // set first tab modal target
    if (typeof isModal !== 'undefined') {
        $addButton
            .addClass(activeTabClass)
            .attr('data-target', '#modal-' + activeTabClass)
            .attr('data-toggle', 'modal')
            .attr('data-remote', '');
    } else {
        $addButton
            .attr('data-toggle', '')
            .attr('data-remote', 'true')
            .attr('href', source)
            .addClass(activeTabClass);

        submitBtn.attr('form', 'form-' + activeTabClass);
    }
}

function enableCurrentTab(activeTab) {
    places = ["#sites", "#zones", "#routes"];
    things = ["#vehicles", "#devices", "#shifts"];
    $(".resource-headers a.active").removeClass("active")

    if (places.includes(activeTab)) {
        showPlaces();
    }else if (things.includes(activeTab)) {
        showThings();
    }else {
        $(".resource-headers a:first-child").addClass("active");
        $(".things").hide();
        $(".places").hide();
        $(".people").show();
    }
}

function showPlaces() {
    $(".resource-headers a:nth-child(2)").addClass("active");
    $(".people").hide();
    $(".things").hide();
    $(".places").show();
}

function showThings() {
    $(".resource-headers a:nth-child(3)").addClass("active");
    $(".people").hide();
    $(".places").hide();
    $(".things").show();
}

function showDefaultResource() {
    $(".resource-headers a:first-child").addClass("active");
    $(".things").hide();
    $(".places").hide();
    $(".people").show();
    $(".people ul li a.people.default:first").size() > 0 ? $(".people ul li a.people.default:first").click() : $(".people ul li a.people:first").click();
}

function showErrorMessage(msg) {
    $('#error-placement').html('<div class="alert alert-danger fade in"><button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>' + msg + '</div>');
}

function removeErrorMessage(msg) {
    $('#error-placement').html('');
}
