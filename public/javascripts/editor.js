$('body').addClass($(location).attr('pathname').replace(/\//g,' nk-'));

$(function() {
	$('.btn-color').colorpicker().on('changeColor', function(e) {
		color = e.color.toHex();
		$(this).css({'color':color});
		$('.editor').css({'color':color});
	});

	$('.editor').focus();

	var cssElement = $('.editor');

	function cssUpdate(element,singleStyleAdjustment) {
		var key = Object.keys(singleStyleAdjustment)[0];
		var val = singleStyleAdjustment[key];
		if ( $(element).css(key) == val ) {
			singleStyleAdjustment[key] = '';
			$(element).css(singleStyleAdjustment);
		} else {
			$(element).css(singleStyleAdjustment);
		}
	}

	$('.btn-bold').click(function(){
		if ($(this).hasClass('active')) { return false; }
		cssUpdate(cssElement,{'font-weight':'bold'});
		$(this).toggleClass('active');
	});

	$('.btn-italic').click(function(){
		if ($(this).hasClass('active')) { return false; }
		cssUpdate(cssElement,{'font-style':'italic'});
		$(this).toggleClass('active');
	});

	$('.btn-strikethrough').click(function(){
		if ($(this).hasClass('active')) { return false; }
		cssUpdate(cssElement,{'text-decoration':'line-through'});
		$('.btn-decoration').removeClass('active');
		$(this).toggleClass('active');
	});

	$('.btn-underline').click(function(){
		if ($(this).hasClass('active')) { return false; }
		cssUpdate(cssElement,{'text-decoration':'underline'});
		$('.btn-decoration').removeClass('active');
		$(this).toggleClass('active');
	});

	$('.btn-small').click(function(){
		if ($(this).hasClass('active')) { return false; }
		$(cssElement).css({'font-size':'75%'});
		$('.btn-size').removeClass('active');
		$(this).addClass('active');
	});

	$('.btn-normal').click(function(){
		if ($(this).hasClass('active')) { return false; }
		$(cssElement).css({'font-size':'100%'});
		$('.btn-size').removeClass('active');
		$(this).addClass('active');
	});

	$('.btn-large').click(function(){
		if ($(this).hasClass('active')) { return false; }
		$(cssElement).css({'font-size':'150%'});
		$('.btn-size').removeClass('active');
		$(this).addClass('active');
	});

	$('.btn-align-left').click(function(){
		if ($(this).hasClass('active')) { return false; }
		$(cssElement).css({'text-align':'left'});
		$('.btn-align').removeClass('active');
		$(this).addClass('active');
	});

	$('.btn-align-center').click(function(){
		if ($(this).hasClass('active')) { return false; }
		$(cssElement).css({'text-align':'center'});
		$('.btn-align').removeClass('active');
		$(this).addClass('active');
	});

	$('.btn-align-right').click(function(){
		if ($(this).hasClass('active')) { return false; }
		$(cssElement).css({'text-align':'right'});
		$('.btn-align').removeClass('active');
		$(this).addClass('active');
	});

	$('.btn-reset').click(function(){
		$('.editor').removeAttr('style');
		$('.btn-align').removeClass('active');
		$('.btn-align-left').addClass('active');
		$('.btn-size').removeClass('active');
		$('.btn-normal').addClass('active');
		$('.btn-style').removeClass('active');
		$('.btn-color').css({'color':'#333333'});
	});

	function showSyncAlert () {
		$('.updated-alert').css({'visibility':'visible'});
	}

	function hideSyncAlert () {
		$('.updated-alert').css({'visibility':'hidden'});
	}

	tinymce.init({ 
		selector:'#mce-editor',
		theme: 'modern',
		menubar: 'edit insert view format table tools',
		plugins: [
			'advlist autolink lists link image charmap preview hr anchor pagebreak',
			'searchreplace wordcount visualblocks visualchars code fullscreen',
			'insertdatetime nonbreaking save table contextmenu directionality',
			'paste textcolor colorpicker textpattern imagetools'
		],
		toolbar1: 'insertfile undo redo | styleselect | bold italic | forecolor backcolor | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image | code',
		image_advtab: true,
		browser_spellcheck: true,
		content_css : '/stylesheets/editor-content.css',
		// statusbar: false,
		auto_focus: 'mce-editor',
		setup : function(editor) {
			editor.on('change', function(event) {
				// console.debug(event.type);
				showSyncAlert();
			});
			editor.on('keyup', function(event) {
				// console.debug(event.type);
				showSyncAlert();
			});
		}
	});

	$('.btn-sync-mce').click(function() {
		var current_content = tinymce.activeEditor.getContent({format : 'raw'});
		var fields = {
			info: "Sync Click MCE",
			body: current_content,
			customFields: {
				"nretnil_mce|fake_info": "fake_info",
				"nretnil_mce|important_info": "important_info",
				"nretnil_mce_local|fake_info": "fake_info",
				"nretnil_mce_local|important_info": "important_info"
			}
		};
		hideSyncAlert();
		console.debug(fields);
		parent.postMessage(fields, "*");
	});

	$('.btn-sync-editor').click(function() {
		var current_content = $('.editor').text();
		var style = $('.editor').attr('style');
		var with_style = '<div style="' + style + '">' + current_content + '</div>';
		var fields = {
			info: "Sync Click Editor",
			body: with_style,
			customFields: {
				"nretnil_editor|one": "one",
				"nretnil_editor|two": "two",
				"nretnil_editor|three": "three",
				"nretnil_editor|four": "four",
				"nretnil_editor_local|one": "one",
				"nretnil_editor_local|two": "two",
				"nretnil_editor_local|three": "three",
				"nretnil_editor_local|four": "four"
			}
		};
		hideSyncAlert();
		console.debug(fields);
		parent.postMessage(fields, "*");
	});

});