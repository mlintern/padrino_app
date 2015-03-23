function flashSuccess (message) {
	$('.flash-notice').html('<div class="alert alert-success" role="alert">'+message+'</div>');
	window.scrollTo(0,0);
	setTimeout(function () { $('.flash-notice').html('')}, 3000);
}

function flashError (message) {
	$('.flash-notice').html('<div class="alert alert-danger" role="alert">'+message+'</div>');
	window.scrollTo(0,0);
	setTimeout(function () { $('.flash-notice').html('')}, 5000);
}

function updatePhoto () {
  id = $(".user-info").data('user-id');
  photo = $('.photo-url').val()
  data = { "properties" : [ { "name":"photo", "value": photo } ] }
  $.ajax({
		url: '/api/accounts/'+id,
		data: JSON.stringify(data),
		dataType: 'json',
    contentType: "application/json",
		type: 'PUT',
		success: function(response) {
			console.log(response);
			$('.user-photo').attr('src', photo);	
			flashSuccess('Account photo updated successfully.');
		},
		error: function(response) {
			console.log(response);
			flashError(response['responseText']);
		}
	});
}