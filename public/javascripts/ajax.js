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
			$('.user-photo').attr('src', photo);	
			console.log(response);
		},
		error: function(response) {
			console.log(response);
		}
	});
}