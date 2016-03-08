$.fn.serializeObject = function()
{
	var o = {};
	var a = this.serializeArray();
	$.each(a, function() {
		if (o[this.name] !== undefined) {
			if (!o[this.name].push) {
				o[this.name] = [o[this.name]];
			}
			o[this.name].push(this.value || '');
		} else {
			o[this.name] = this.value || '';
		}
	});
	return o;
};

$.fn.serializeForm = function()
{
	var self = this.find('input,select');
	var o = {};
	$.each(self, function() {
		input = $(this);
		if ( input.attr("name") !== undefined ) {
			if (input.attr("type") == "checkbox") {
				o[input.attr("name")] = input.is(':checked');
			} else {
				o[input.attr("name")] = input.val();
			}
		}
	});
	return o;
};

function flashSuccess (message) {
	$('.flash-notice').html('<div class="alert alert-success" role="alert">'+message+'</div>');
	window.scrollTo(0,0);
	_.delay(function () { $('.flash-notice').html('')}, 3000);
}

function flashError (message) {
	$('.flash-notice').html('<div class="alert alert-danger" role="alert">'+message+'</div>');
	window.scrollTo(0,0);
	_.delay(function () { $('.flash-notice').html('')}, 5000);
}

function updatePhoto () {
	id = $(".user-info").data('user-id');
	photo = $('.photo-url').val()
	data = { "properties" : [ { "name":"photo", "value": photo } ] };
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

function clearPhoto () {
	id = $(".user-info").data('user-id');
	data = { "properties" : [ { "name":"photo", "value": null } ] };
	$.ajax({
		url: '/api/accounts/'+id,
		data: JSON.stringify(data),
		dataType: 'json',
		contentType: "application/json",
		type: 'PUT',
		success: function(response) {
			console.log(response);
			$('.user-photo').attr('src', '/images/default.png');
			$('.photo-url').val('')
			flashSuccess('Account photo cleared successfully.');
		},
		error: function(response) {
			console.log(response);
			flashError(response['responseText']);
		}
	});
}

function resetAuthToken (id) {
	data = {};
	$.ajax({
		url: '/api/accounts/'+id+'/auth_token',
		data: JSON.stringify(data),
		dataType: 'json',
		contentType: "application/json",
		type: 'PUT',
		success: function(response) {
			$('.auth-token').text(response["auth_token"]);
			flashSuccess('Auth Token Reset.');
		},
		error: function(response) {
			flashError(response['responseText']);
		}
	});
}

function startProject () {
	var id = $(".btn-start").data('project');
	var data = {};
	$.ajax({
		url: '/api/projects/'+id+'/start',
		data: JSON.stringify(data),
		dataType: 'json',
		contentType: "application/json",
		type: 'POST',
		success: function(response) {
			flashSuccess(response["info"]);
			setTimeout(function() { location.reload() }, 1000 );
		},
		error: function(response) {
			flashError(response['responseText']);
		}
	});
}

function cancelProject () {
	var id = $(".btn-cancel").data('project');
	var data = {};
	$.ajax({
		url: '/api/projects/'+id+'/cancel',
		data: JSON.stringify(data),
		dataType: 'json',
		contentType: "application/json",
		type: 'POST',
		success: function(response) {
			flashSuccess(response["info"]);
			setTimeout(function() { location.reload() }, 1000 );
		},
		error: function(response) {
			flashError(response['responseText']);
		}
	});
}

function completeProject () {
	var id = $(".btn-complete").data('project');
	var data = {};
	$.ajax({
		url: '/api/projects/'+id+'/complete',
		data: JSON.stringify(data),
		dataType: 'json',
		contentType: "application/json",
		type: 'POST',
		success: function(response) {
			flashSuccess(response["info"]);
			setTimeout(function() { location.reload() }, 1000 );
		},
		error: function(response) {
			flashError(response['responseText']);
		}
	});
}

function deleteAsset (asset_id) {
	$.ajax({
		url: "/api/assets/"+asset_id,
		dataType: 'json',
		contentType: "application/json",
		type: 'DELETE',
		success: function(response) {
			$('tr[data-asset='+asset_id+']').remove();
			flashSuccess(response["info"]);
		},
		error: function(response) {
			flashError(response['responseText']);
		}
	});
}

function deleteProject (project_id) {
	$.ajax({
		url: "/api/projects/"+project_id,
		dataType: 'json',
		contentType: "application/json",
		type: 'DELETE',
		success: function(response) {
			$('tr[data-project='+project_id+']').remove();
			flashSuccess(response["info"]);
		},
		error: function(response) {
			flashError(response['responseText']);
		}
	});
}

function translateAsset (asset_id,refresh) {
	refresh = typeof refresh !== 'undefined' ? refresh : false;
	var data = {};
	$.ajax({
		url: "/api/assets/"+asset_id+"/translate",
		data: JSON.stringify(data),
		dataType: 'json',
		contentType: "application/json",
		type: 'POST',
		success: function(response) {
			$('.btn-translate').remove();
			flashSuccess("Successfully Translated.");
			if (refresh) {
				setTimeout(function() { location.reload() }, 1000 );
			}
		},
		error: function(response) {
			flashError(response['responseText']);
			if (refresh) {
				setTimeout(function() { location.reload() }, 1000 );
			}
		}
	});
}

function updateProject (project_id) {
	var newTitle = $('#project-title').val();
	var newDesc = $('#project-desc').val();
	var data = { "name" : newTitle, 'description' : newDesc };
	$.ajax({
		url: "/api/projects/"+project_id,
		data: JSON.stringify(data),
		dataType: 'json',
		contentType: "application/json",
		type: 'PUT',
		success: function(response) {
			$('.project-title').text(response['name']);
			$('.project-desc').text(response['description']);
			flashSuccess("Title Successfully Updated");
		},
		error: function(response) {
			flashError(response['responseText']);
		}
	});
}

function deleteLanguage (language_id) {
	$.ajax({
		url: "/api/languages/"+language_id,
		dataType: 'json',
		contentType: "application/json",
		type: 'DELETE',
		success: function(response) {
			$('tr[data-language='+language_id+'],span[data-language='+language_id+']').remove();
			flashSuccess(response["info"]);
		},
		error: function(response) {
			flashError(response['responseText']);
		}
	});
}

function addLanguage (project_id) {
	var name = $('#language-name').val();
	var code = $('#language-code').val();
	var data = { "project_id" : project_id, 'name' : name, 'code' : code };
	$.ajax({
		url: "/api/languages",
		data: JSON.stringify(data),
		dataType: 'json',
		contentType: "application/json",
		type: 'POST',
		success: function(response) {
			$('.add-language').hide();
			$('.language-list').append('<span data-language="'+response["id"]+'"> '+response["name"]+' ('+response["code"]+')  </span>');
			$('.table-language-list').append('<tr data-language="'+response["id"]+'" class="list-row"><td class=list-column> '+response["name"]+' </td><td class=list-column> '+response["code"]+' </td><td> Refresh to Delete</td></tr>');
			flashSuccess("Language Successfully Added.");
		},
		error: function(response) {
			flashError(response['responseText']);
		}
	});
}

function addAsset (project_id, language) {
	var title = $('#asset-title').val();
	var body = $('#asset-body').val();
	if ( title.length < 1 || body.length < 1 ) {
		alert("Must fillout Title and Body fields");
	} else {
		var data = { "project_id" : project_id, 'title' : title, 'body' : body, 'language' : language };
		$.ajax({
			url: "/api/projects/"+project_id+"/assets",
			data: JSON.stringify(data),
			dataType: 'json',
			contentType: "application/json",
			type: 'POST',
			success: function(response) {
				$('.new-asset').modal('hide');
				flashSuccess("Asset Successfully Added.");
				setTimeout(function() { location.reload() }, 1000 );
			},
			error: function(response) {
				flashError(response['responseText']);
			}
		});
	}
}

function updateTranslator () {
	event.preventDefault();
	var data = $('.translation-settings-form').serializeForm();
	$.ajax({
		url: "/api/translator/configure",
		data: JSON.stringify(data),
		dataType: 'json',
		contentType: "application/json",
		type: 'POST',
		success: function(response) {
			flashSuccess("Translator Successfully Updated.");
		},
		error: function(response) {
			flashError(response['responseText']);
		}
	});
}

function deleteTranslator () {
	event.preventDefault();
	var data = $('.translation-settings-form').serializeForm();
	var app_install_id = data["app_install_id"]
	$.ajax({
		url: "/api/translator/"+app_install_id,
		dataType: 'json',
		contentType: "application/json",
		type: 'DELETE',
		success: function(response) {
			$('.translator-settings').modal('hide');
			flashSuccess("Translator Deleted Successfully.");
			setTimeout(function() { location.reload() }, 1000 );
		},
		error: function(response) {
			flashError(response['responseText']);
		}
	});
}