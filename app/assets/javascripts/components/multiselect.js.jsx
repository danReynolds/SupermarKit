var Multiselect = React.createClass({
    propTypes: {
        selection: React.PropTypes.array,
        removeFromSelection: React.PropTypes.func,
        hiddenField: React.PropTypes.string,
        backspaceTarget: React.PropTypes.number,
        removable: React.PropTypes.bool
    },

    getDefaultProps: function() {
        return {
            selection: [],
            removable: false
        }
    },

    handleRemove: function(event) {
        this.props.removeFromSelection(parseInt(event.target.closest('.chip').getAttribute('data-id')));
    },

    render: function() {
        var selection = this.props.selection.map(function(selected, index) {
            return (
                <Chip
                    key={"selection-" + index}
                    index={index}
                    active={this.props.backspaceTarget === index}
                    label={selected.name}
                    handleRemove={this.props.removable ? this.handleRemove : null}
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
