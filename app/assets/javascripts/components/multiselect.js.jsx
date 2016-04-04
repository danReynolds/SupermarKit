var Multiselect = React.createClass({
    propTypes: {
        selection: React.PropTypes.array,
        removeFromSelection: React.PropTypes.func,
        hiddenField: React.PropTypes.string,
        backspaceTarget: React.PropTypes.number
    },

    getDefaultProps: function() {
        return {
            selection: []
        }
    },

    handleRemove: function(event) {
        this.props.removeFromSelection(parseInt(event.target.closest('.chip').getAttribute('data-id')));
    },

    render: function() {
        if (this.props.removeFromSelection) {
            remove = <i className='fa fa-close' onClick={this.handleRemove}/>;
        }

        var selection = this.props.selection.map(function(selected, index) {
            return (
                <Chip
                    key={"selection-" + index}
                    index={index}
                    active={this.props.backspaceTarget === index}
                    label={selected.name}
                    handleRemove={this.handleRemove}
                    gravatar={selected.gravatar}/>
            );
        }.bind(this));

        return (
            <div className='multiselect' ref='root'>
                <div className='selection-container valign-wrapper'>
                    {selection}
                </div>
            </div>
        );
    },

    componentDidUpdate: function(prevProps, prevState) {
        if (this.props.selection !== prevProps.selection) {
            this.setState({ selection: this.props.selection });
        }
    }
});
