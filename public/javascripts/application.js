$('body').addClass($(location).attr('pathname').replace(/\//g,' nk-'));

!function($) {
	'use strict';

	$(function() {

		function toggleAction  (selector, disabled) {
			var method = disabled ? 'addClass' : 'removeClass';
			$(selector)[method]('list-menu-link-disabled').parent()[method]('list-menu-wrapper-disabled');
		}

		// Check/uncheck all functionality
		function checkAll (base, checked) {
			// Toggle all checkboxes on the table's body that exist on the first column.
			base.find(listCheckboxesSelector).prop('checked', checked);
			base.find('.list-row')[checked ? 'addClass' : 'removeClass']('list-row-selected');
			toggleAction('#delete-selected', !checked);
		}

		function generalToggle () {
			var checked = listCheckboxes.filter(':checked').length;
			toggleAction('#delete-selected', checked === 0);
			toggleAction('#deselect-all', checked === 0);
			toggleAction('#select-all', checked === listCheckboxesLength);
		}

		function validateCredentials () {
			// Comepndium API Form Validation
			var f1 = new LiveValidation( 'f1', { onlyOnSubmit: true } );
			f1.add( Validate.Presence );

			var f2 = new LiveValidation( 'f2', { onlyOnSubmit: true } );
			f2.add( Validate.Presence );

			var automaticOnSubmit = f1.form.onsubmit;
		}

		function setFields () {
			if ( $('#public').is(':checked') ) {
				$('.auth').show();
				$(".not-pub").prop('disabled',false);
				validateCredentials();
			} else {
				$('.auth').hide();
				$('#method').prop('selectedIndex', 0);
				$(".not-pub").prop('disabled',true);
			}

			var method = $('#method').val();

			if ( method == 'get' || method == 'delete' ) {
				$('.query').show();
				$('.body').hide();
			} else {
				$('.query').hide();
				$('.body').show();
			}
		}

		$('#public').change(function() { setFields(); } );
		$('#method').change(function() { setFields(); } );

		$('.screenshot img').click(function() {
			var url = $(this).attr('src');
			window.open(url);
			return true;
		});

		var listCheckboxesSelector = '.list-selectable-checkbox', list = $('#list'), alertTimeout = 4000, listCheckboxes, listCheckboxesLength;

		// Automatically close alerts if there was any present.
		if ($('.alert').length > 0) {
			setTimeout(function() { $('.alert').alert('close'); }, alertTimeout);
		}

		listCheckboxes = list.find(listCheckboxesSelector);
		listCheckboxesLength = listCheckboxes.length;

		// Confirm before deleting one item
		$('.list-row-action-delete-one').on('click', function(ev) {
			ev.preventDefault();
			$(this).addClass('list-row-action-wrapper-link-active')
				.siblings('.list-row-action-popover-delete-one').first().show()
				.find('.cancel').on('click', function() {
					$(this).parents('.list-row-action-popover-delete-one').hide()
						.siblings('.list-row-action-delete-one').removeClass('list-row-action-wrapper-link-active');
				});
		});

		// Select/deselect record on row's click
		list.find('.list-row').click( function(ev) {
			var checkbox, willBeChecked;
			ev.stopPropagation();

			if (ev.currentTarget.tagName == 'TR') {
				checkbox = $(this).find('.list-selectable-checkbox');
				willBeChecked = !checkbox.prop('checked');
				checkbox.prop('checked', willBeChecked);
				$(this)[willBeChecked ? 'addClass' : 'removeClass']('list-row-selected');
				generalToggle();
			}
		});
		// Select all action
		$('#select-all').click( function(ev) {
			ev.preventDefault();
			ev.stopPropagation();
			if ($(this).is('.list-menu-link-disabled')) return;

			// We assume we want to stay on the dropdown to delete all perhaps
			ev.stopPropagation();
			checkAll(list, true);
			toggleAction('#select-all', true);
			toggleAction('#deselect-all', false);
		});
		// Deselect all action
		$('#deselect-all').click( function(ev) {
			ev.preventDefault();
			if ($(this).is('.list-menu-link-disabled')) return;

			checkAll(list, false);
			toggleAction('#deselect-all', true);
			toggleAction('#select-all', false);
		});
		// Delete selected
		$('#delete-selected').on('click', function(ev) {
			ev.preventDefault();
			ev.stopPropagation();
			if ($(this).is('.list-menu-link-disabled')) return;

			// Open the popup to confirm deletion
			$(this).parent().addClass('active').parent('.dropdown').addClass('open');
			$(this).addClass('active')
				.siblings('.list-menu-popover-delete-selected').first().show()
				.find('.cancel').on('click', function() {

					// Hide the popover on cancel
					$(this).parents('.list-menu-popover-delete-selected').hide()
						.siblings('#delete-selected').removeClass('active').parent().removeClass('active');
					// and close the dropdown
					$(this).parents('.dropdown').removeClass('open');
				});

			$(this).siblings('.list-menu-popover-delete-selected').find(':hidden[data-delete-many-ids=true]').
				val(listCheckboxes.filter(':checked').map(function() { return $(this).val(); }).toArray().join(','));
		});

		// Catch checkboxes check/uncheck and enable/disable the delete selected functionality
		listCheckboxes.click(function(ev) {
			ev.stopPropagation();

			$(this).parent('.list-row')[$(this).is(':checked') ? 'addClass' : 'removeClass']('list-row-selected');

			generalToggle();
		});

		setFields();

		if ( $('#r1').length ) {
			// Comepndium API Form Validation
			var r1 = new LiveValidation( 'r1', { onlyOnSubmit: true } );
			r1.add( Validate.Presence );

			var r2 = new LiveValidation( 'r2', { onlyOnSubmit: true } );
			r2.add( Validate.Presence );

			var r3 = new LiveValidation( 'r3', { onlyOnSubmit: true } );
			r3.add( Validate.Presence );
			r3.add( Validate.Email );

			var automaticOnSubmit = r1.form.onsubmit;
		}

		// Autofocus first field with an error. (usability)
		var error_input;
		if (error_input == $('.has-error :input').first()) { error_input.focus(); }

		$('.toggle-right-nav').click(function (e) {
			e.preventDefault();
			$('.left-nav-hidden').hide();
			$('.right-nav-hidden').toggle();
		});
		$('.toggle-left-nav').click(function (e) {
			e.preventDefault();
			$('.right-nav-hidden').hide();
			$('.left-nav-hidden').toggle();
		});

		$('[data-toggle="tooltip"]').tooltip();

		$('.menu-trigger').click(function(event){
			event.preventDefault();
			if ($('.alta-dropdown-menu').hasClass('open')) {
				$('.alta-dropdown-menu').removeClass('open');
				$('.alta-main-container').removeClass('nav-open');
				$('.alta-dropdown-menu').find('.has-sub-menu').removeClass('open');
				$('.menu-trigger .fa').addClass('fa-bars');
				$('.menu-trigger .fa').removeClass('fa-arrow-left');
			} else {
				$('.alta-dropdown-menu').addClass('open');
				$('.alta-main-container').addClass('nav-open');
				$('.menu-trigger .fa').removeClass('fa-bars');
				$('.menu-trigger .fa').addClass('fa-arrow-left');
			}
		});

		$('.alta-main-menu li .toggle-menu').click(function(event){
			if ($(this).parent().find('.alta-sub-menu').length) {
				event.preventDefault();
				if ($(this).parent().find('.alta-sub-menu').hasClass('open')) {
					$(this).parent().find('.alta-sub-menu').removeClass('open');
					$(this).removeClass('active');
				} else {
					$('.alta-sub-menu').removeClass('open');
					$('.alta-main-menu li a').removeClass('active');
					$(this).parent().find('.alta-sub-menu').addClass('open');
					$(this).addClass('active');
				}
			}
		});

		$('.alta-user-menu .toggle-menu').click(function(event){
			event.preventDefault();
			if ($('.alta-user-menu .alta-user-dropdown').hasClass('open')) {
				$('.alta-user-menu .alta-user-dropdown').removeClass('open');
				$(this).removeClass('active');
			} else {
				$('.alta-user-menu .alta-user-dropdown').addClass('open');
				$(this).addClass('active');
			}
		});

		$('.mobile-close').click(function(event){
			event.preventDefault();
			$('.alta-dropdown-menu').removeClass('open');
			$('.alta-main-container').removeClass('nav-open');
			$('.alta-dropdown-menu').find('.has-sub-menu').removeClass('open');
			$('.menu-trigger .fa').addClass('fa-bars');
			$('.menu-trigger .fa').removeClass('fa-arrow-left');
		});

		// File Upload JS v
	  var bar = $('.progress-bar');
	  var percent = $('.percent');
	  var status = $('#status');

	  function reset () {
	    status.empty();
	    var percentVal = '0%';
	    bar.width(percentVal);
	    percent.html(percentVal);
	  }

	  $('#files').change(function(){
	    reset();
	  });

	  $('form').ajaxForm({
	    beforeSend: function() {
	      reset();
	    },
	    uploadProgress: function(event, position, total, percentComplete) {
	      var percentVal = percentComplete + '%';
	      bar.width(percentVal);
	      percent.html(percentVal);
	    },
	    success: function() {
	      var percentVal = '100%';
	      bar.width(percentVal);
	      percent.html(percentVal);
	    },
	    complete: function(xhr) {
	      var response_html = "";
	      var files = JSON.parse(xhr.responseText).files;
	      $.each(files, function (x,file) {
	        response_html += '<span class="badge badge-success m-1 p-2">' + file.name + ' (' + file.size + ')</span>';
	      });
	      status.html(response_html);
	      $('.input-information').hide();
	    }
	  });

	  $("#files").on('change', function() {
	    console.log('updating');
	    var html = '';
	    for (var i = 0; i < $(this).get(0).files.length; ++i) {
	        html += '<span class="badge badge-secondary m-1 p-2">' + $(this).get(0).files[i].name + '</span>';
	    }
	    $('.input-information').html(html);
	    $('.input-information').show();
	  });

	});

}(window.jQuery);
