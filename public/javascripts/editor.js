$('body').addClass($(location).attr('pathname').replace(/\//g,' nk-'));

$(function() {
	$('.btn-color').colorpicker().on('changeColor', function(e) {
		color = e.color.toHex();
		$(this).css({'color':color});
		$('.editor').css({'color':color});
	});

	$('.editor').focus();

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
		cssUpdate('.editor',{'font-weight':'bold'});
		$(this).toggleClass('active');
	});

	$('.btn-italic').click(function(){
		if ($(this).hasClass('active')) { return false; }
		cssUpdate('.editor',{'font-style':'italic'});
		$(this).toggleClass('active');
	});

	$('.btn-strikethrough').click(function(){
		if ($(this).hasClass('active')) { return false; }
		cssUpdate('.editor',{'text-decoration':'line-through'});
		$('.btn-decoration').removeClass('active');
		$(this).toggleClass('active');
	});

	$('.btn-underline').click(function(){
		if ($(this).hasClass('active')) { return false; }
		cssUpdate('.editor',{'text-decoration':'underline'});
		$('.btn-decoration').removeClass('active');
		$(this).toggleClass('active');
	});

	$('.btn-small').click(function(){
		if ($(this).hasClass('active')) { return false; }
		$('.editor').css({'font-size':'75%'});
		$('.btn-size').removeClass('active');
		$(this).addClass('active');
	});

	$('.btn-normal').click(function(){
		if ($(this).hasClass('active')) { return false; }
		$('.editor').css({'font-size':'100%'});
		$('.btn-size').removeClass('active');
		$(this).addClass('active');
	});

	$('.btn-large').click(function(){
		if ($(this).hasClass('active')) { return false; }
		$('.editor').css({'font-size':'150%'});
		$('.btn-size').removeClass('active');
		$(this).addClass('active');
	});

	$('.btn-align-left').click(function(){
		if ($(this).hasClass('active')) { return false; }
		$('.editor').css({'text-align':'left'});
		$('.btn-align').removeClass('active');
		$(this).addClass('active');
	});

	$('.btn-align-center').click(function(){
		if ($(this).hasClass('active')) { return false; }
		$('.editor').css({'text-align':'center'});
		$('.btn-align').removeClass('active');
		$(this).addClass('active');
	});

	$('.btn-align-right').click(function(){
		if ($(this).hasClass('active')) { return false; }
		$('.editor').css({'text-align':'right'});
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
		// statusbar: false,
		auto_focus: 'mce-editor'
	});
});