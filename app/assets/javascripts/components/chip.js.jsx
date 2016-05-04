var Chip = React.createClass({
    propTypes: {
        label: React.PropTypes.string.isRequired,
        active: React.PropTypes.bool,
        index: React.PropTypes.number.isRequired,
        gravatar: React.PropTypes.string,
        handleRemove: React.PropTypes.func
    },

    getDefaultProps: function() {
        return {
            active: false
        };
    },

    render: function() {
        if (this.props.handleRemove) {
            var remove = <i className='fa fa-close' onClick={this.props.handleRemove}/>;
        }

        if (this.props.gravatar) {
            var gravatar = <img src={this.props.gravatar}/>;
        }

        return (
            <div
                className={this.props.active ? 'chip active' : 'chip'}
                data-id={this.props.index}>
                {gravatar}
                {this.props.label}
                {remove}
            </div>
        );
    }
});
