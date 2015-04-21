/*jshint quotmark:false */
/*jshint white:false */
/*jshint trailing:false */
/*jshint newcap:false */
/*global React, Router*/
var app = app || {};

(function () {
	'use strict';

	var Utils = app.Utils;

	app.ALL_TODOS = 'all';
	app.ACTIVE_TODOS = 'active';
	app.COMPLETED_TODOS = 'completed';
	var TodoFooter = app.TodoFooter;
	var TodoItem = app.TodoItem;

	var ENTER_KEY = 13;

	var TodoApp = React.createClass({
		getInitialState: function () {
			return {
				todos: [],
				nowShowing: app.ACTIVE_TODOS,
				editing: null
			};
		},

		componentDidMount: function () {
			$.get('/api/todos', function (data) {
				if (this.isMounted()) {
					this.setState({
						todos: data
					});
				}
			}.bind(this));
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

			var val = this.refs.newField.getDOMNode().value.trim();

			if (val) {
				Utils.addTodo({"title":val});
				this.refs.newField.getDOMNode().value = '';
				this.componentDidMount();
			}
		},

		toggleAll: function (event) {
			var checked = event.target.checked;
			_.each(this.state.todos,function (todo) {
				Utils.updateTodo(todo.id,{ "completed" : checked });
			})
			this.componentDidMount();
		},

		toggle: function (todoToToggle) {
			Utils.updateTodo(todoToToggle["id"],{ "completed" : !todoToToggle.completed });
			this.componentDidMount();
		},

		destroy: function (todo) {
			Utils.deleteTodo(todo.id);
			this.componentDidMount();
		},

		edit: function (todo) {
			this.setState({editing: todo.id});
		},

		save: function (todoToSave, text) {
			Utils.updateTodo(todoToSave.id, {"title":text});
			this.setState({editing: null});
			this.componentDidMount();
		},

		cancel: function () {
			this.setState({editing: null});
			this.componentDidMount();
		},

		clearCompleted: function () {
			_.each(this.state.todos,function (todo) {
				if (todo.completed) { Utils.deleteTodo(todo.id); }
			})
			this.componentDidMount();
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
					<section id="main">
						<input
							id="toggle-all"
							type="checkbox"
							onChange={this.toggleAll}
							checked={activeTodoCount === 0}
						/>
						<ul id="todo-list">
							{todoItems}
						</ul>
					</section>
				);
			}

			return (
				<div>
					<header id="header">
						<input
							ref="newField"
							id="new-todo"
							placeholder="What needs to be done?"
							onKeyDown={this.handleNewTodoKeyDown}
							autoFocus={true}
						/>
					</header>
					{footer}
					{main}
				</div>
			);
		}
	});

	function render() {
		React.render(
			<TodoApp/>,
			document.getElementById('todo')
		);
	}

	render();

})();
