import React, { Component } from "react";
import CreateReactClass from 'create-react-class';
import ReactDOM from "react-dom";
import TodoItem from "./todoItem.jsx";
import TodoFooter from "./footer.jsx";

var app = app || {};

app.ALL_TODOS = 'all';
app.ACTIVE_TODOS = 'active';
app.COMPLETED_TODOS = 'completed';

var ENTER_KEY = 13;

var TodoApp = CreateReactClass({
	getInitialState: function () {
		return {
			todos: [],
			nowShowing: app.ACTIVE_TODOS,
			editing: null
		};
	},

	componentDidMount() {
		fetch('/api/todos')
			.then(response => response.json())
			.then(data => this.setState({ todos: data }));
	},

	update: _.throttle( function () {
		var self = this;
		$.get('/api/todos', function (data) {
			self.setState({
				todos: data
			});
		});
	},1000),

	addTodo: function (data) {
		var self = this;
		$.ajax({
			url: '/api/todos',
			data: JSON.stringify(data),
			dataType: 'json',
			contentType: "application/json",
			type: 'POST',
			success: function(response) {
				self.update();
			},
			error: function(response) {
				console.log(response);
				flashError(response['responseText']);
			}
		});
	},

	updateTodo: function (id,data) {
		var self = this;
		$.ajax({
			url: '/api/todos/'+id,
			data: JSON.stringify(data),
			dataType: 'json',
			contentType: "application/json",
			type: 'PUT',
			success: function(response) {
				// console.log(response);
				self.update();
			},
			error: function(response) {
				console.log(response);
				flashError(response['responseText']);
			}
		});
	},

	allTodos: function () {
		this.setState({nowShowing: app.ALL_TODOS});
	},

	activeTodos: function () {
		this.setState({nowShowing: app.ACTIVE_TODOS});
	},

	completedTodos: function () {
		this.setState({nowShowing: app.COMPLETED_TODOS});
	},

	handleNewTodoKeyDown: function (event) {
		if (event.which !== ENTER_KEY) {
			return;
		}

		event.preventDefault();

		var val = ReactDOM.findDOMNode(this.refs.newField).value.trim();

		if (val) {
			this.addTodo({"title":val});
			ReactDOM.findDOMNode(this.refs.newField).value = '';
		}
	},

	toggleAll: function (event) {
		var checked = event.target.checked;
		var that = this;
		_.each(this.state.todos,function (todo) {
			that.updateTodo(todo.id,{ "completed" : checked });
		})
	},

	toggle: function (todoToToggle) {
		this.updateTodo(todoToToggle["id"],{ "completed" : !todoToToggle.completed });
	},

	destroy: function (todo) {
		var self = this;
		$.ajax({
			url: '/api/todos/'+todo.id,
			dataType: 'json',
			contentType: "application/json",
			type: 'DELETE',
			success: function(response) {
				self.update();
			},
			error: function(response) {
				console.log(response.responseText);
				flashError(response['responseText']);
			}
		});
	},

	edit: function (todo) {
		this.setState({editing: todo.id});
	},

	save: function (todoToSave, text) {
		this.updateTodo(todoToSave.id, {"title":text});
		this.setState({editing: null});
	},

	cancel: function () {
		this.setState({editing: null});
		this.componentDidMount();
	},

	clearCompleted: function () {
		var that = this;
		_.each(this.state.todos,function (todo) {
			if (todo.completed) { that.destroy(todo); }
		})
	},

	render: function () {
		var footer;
		var main;
		var todos = this.state.todos;

		var shownTodos = todos.filter(function (todo) {
			switch (this.state.nowShowing) {
			case app.ACTIVE_TODOS:
				return !todo.completed;
			case app.COMPLETED_TODOS:
				return todo.completed;
			default:
				return true;
			}
		}, this);

		var todoItems = shownTodos.map(function (todo) {
			return (
				<TodoItem
					key={todo.id}
					todo={todo}
					onToggle={this.toggle.bind(this, todo)}
					onDestroy={this.destroy.bind(this, todo)}
					onEdit={this.edit.bind(this, todo)}
					editing={this.state.editing === todo.id}
					onSave={this.save.bind(this, todo)}
					onCancel={this.cancel}
				/>
			);
		}, this);

		var activeTodoCount = todos.reduce(function (accum, todo) {
			return todo.completed ? accum : accum + 1;
		}, 0);

		var completedCount = todos.length - activeTodoCount;

		if (activeTodoCount || completedCount) {
			footer =
				<TodoFooter
					count={activeTodoCount}
					completedCount={completedCount}
					nowShowing={this.state.nowShowing}
					onClearCompleted={this.clearCompleted}
					allTodos={this.allTodos}
					activeTodos={this.activeTodos}
					completedTodos={this.completedTodos}
				/>;
		}

		if (todos.length) {
			main = (
				<div className="main">
					<input
						className="toggle-all"
						type="checkbox"
						onChange={this.toggleAll}
						checked={activeTodoCount === 0}
					/>
					<ul className="todo-list">
						{todoItems}
					</ul>
				</div>
			);
		}

		return (
			<div>
				<div className="header">
					<input
						ref="newField"
						className="new-todo"
						placeholder="What needs to be done?"
						onKeyDown={this.handleNewTodoKeyDown}
						autoFocus={true}
					/>
				</div>
				{footer}
				{main}
			</div>
		);
	}
});

function render() {
	ReactDOM.render(
		<TodoApp/>,
		document.getElementById('todo')
	);
}

render();
