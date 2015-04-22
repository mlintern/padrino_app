/*jshint quotmark:false */
/*jshint white:false */
/*jshint trailing:false */
/*jshint newcap:false */
/*global React */
var app = app || {};

(function () {
	'use strict';

	app.TodoFooter = React.createClass({
		pluralize: function (count, word) {
			return count === 1 ? word : word + 's';
		},

		render: function () {
			var activeTodoWord = this.pluralize(this.props.count, 'item');
			var clearButton = null;

			if (this.props.completedCount > 0) {
				clearButton = (
					<button
						id="clear-completed"
						onClick={this.props.onClearCompleted}>
						Clear completed ({this.props.completedCount})
					</button>
				);
			}

			// React idiom for shortcutting to `classSet` since it'll be used often
			var cx = React.addons.classSet;
			var nowShowing = this.props.nowShowing;
			return (
				<div className="todo-sort">
					<ul id="filters">
						<li>
							<a href="javascript:void(0)"
								onClick={ this.props.allTodos }
								className={this.props.nowShowing == 'all' ? 'selected' : ''}>
									All
							</a>
						</li>
						{' '}
						<li>
							<a href="javascript:void(0)"
								onClick={ this.props.activeTodos }
								className={this.props.nowShowing == 'active' ? 'selected' : ''}>
									Active
							</a>
						</li>
						{' '}
						<li>
							<a href="javascript:void(0)"
								onClick={ this.props.completedTodos }
								className={this.props.nowShowing == 'completed' ? 'selected' : ''}>
									Completed
							</a>
						</li>
					</ul>
					<span id="todo-count">
						<strong>{this.props.count}</strong> {activeTodoWord} left
					</span>
					{clearButton}
				</div>
			);
		}
	});
})();
