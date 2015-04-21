var app = app || {};

(function () {
	'use strict';

	app.Utils = {
		uuid: function () {
			/*jshint bitwise:false */
			var i, random;
			var uuid = '';

			for (i = 0; i < 32; i++) {
				random = Math.random() * 16 | 0;
				if (i === 8 || i === 12 || i === 16 || i === 20) {
					uuid += '-';
				}
				uuid += (i === 12 ? 4 : (i === 16 ? (random & 3 | 8) : random))
					.toString(16);
			}

			return uuid;
		},

		pluralize: function (count, word) {
			return count === 1 ? word : word + 's';
		},

		addTodo: function (data) {
			//data = { "completed" : true };
			$.ajax({
				url: '/api/todos',
				data: JSON.stringify(data),
				dataType: 'json',
				contentType: "application/json",
				type: 'POST',
				success: function(response) {
					// console.log(response);
				},
				error: function(response) {
					console.log(response);
					flashError(response['responseText']);
				}
			});
		},

		updateTodo: function (id,data) {
			//data = { "completed" : true };
			$.ajax({
				url: '/api/todos/'+id,
				data: JSON.stringify(data),
				dataType: 'json',
				contentType: "application/json",
				type: 'PUT',
				success: function(response) {
					// console.log(response);
				},
				error: function(response) {
					console.log(response);
					flashError(response['responseText']);
				}
			});
		},

		deleteTodo: function (id) {
			$.ajax({
				url: '/api/todos/'+id,
				dataType: 'json',
				contentType: "application/json",
				type: 'DELETE',
				success: function(response) {
					// console.log(response);
				},
				error: function(response) {
					console.log(response.responseText);
					flashError(response['responseText']);
				}
			});
		},

		extend: function () {
			var newObj = {};
			for (var i = 0; i < arguments.length; i++) {
				var obj = arguments[i];
				for (var key in obj) {
					if (obj.hasOwnProperty(key)) {
						newObj[key] = obj[key];
					}
				}
			}
			return newObj;
		}
	};
})();
