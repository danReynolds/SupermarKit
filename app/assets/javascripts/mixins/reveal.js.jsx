var RevealMixin = {
    propTypes: {
        modal: React.PropTypes.object.isRequired
    },

    getInitialState: function() {
        return {
            selection: this.props.selection,
            modalOpen: false
        }
    },

    addToSelection: function(selected) {
        this.setState({
            selection: React.addons.update(this.state.selection, {$push: [selected]})
        });
    },

    removeFromSelection: function(index) {
        this.setState({
            selection: React.addons.update(this.state.selection, {$splice: [[index, 1]]})
        });
    },

    toggleModal: function() {
        this.setState({ modalOpen: !this.state.modalOpen });
    },
}
