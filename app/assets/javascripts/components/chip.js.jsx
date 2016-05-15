var Chip = React.createClass({
    propTypes: {
        label: React.PropTypes.string.isRequired,
        active: React.PropTypes.bool,
        index: React.PropTypes.number.isRequired,
        image: React.PropTypes.string,
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

        if (this.props.image) {
            var image = <img src={this.props.image}/>;
        }

        return (
            <div
                className={this.props.active ? 'chip active' : 'chip'}
                data-id={this.props.index}>
                {image}
                {this.props.label}
                {remove}
            </div>
        );
    }
});
