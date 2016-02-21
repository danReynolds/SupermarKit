var ItemResult = React.createClass({
    propTypes: {
        resultIndex: React.PropTypes.number.isRequired,
        handleAdd: React.PropTypes.func.isRequired,
        result: React.PropTypes.object.isRequired,
        scrollTarget: React.PropTypes.number.isRequired
    },

    render: function() {
        var resultClass = 'valign-wrapper' + (this.props.resultIndex == this.props.scrollTarget ? ' target' : "");

        return (
            <li
                className={resultClass}
                onClick={this.props.handleAdd}
                data-index={this.props.resultIndex}>
                <p>{this.props.result.name}</p>
            </li>
        );
    }
})
