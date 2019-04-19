import React, { Component } from "react";
import CreateReactClass from 'create-react-class';
import ClassNames from 'classnames';
import ReactDOM from "react-dom";

var app = app || {};

var TodoFooter = CreateReactClass({
	pluralize: function (count, word) {
		return count === 1 ? word : word + 's';
	},

	render: function () {
		var activeTodoWord = this.pluralize(this.props.count, 'item');
		var clearButton = null;

		if (this.props.completedCount > 0) {
			clearButton = (
				<button
					className="clear-completed"
					onClick={this.props.onClearCompleted}>
					Clear completed ({this.props.completedCount})
				</button>
			);
		}

		var nowShowing = this.props.nowShowing;
		return (
			<div className="todo-sort">
				<ul className="filters">
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
				<span className="todo-count">
					<strong>{this.props.count}</strong> {activeTodoWord} left
				</span>
				{clearButton}
			</div>
		);
	}
});

export default TodoFooter;
