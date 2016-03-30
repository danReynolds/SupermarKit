var ModalContainer = {
    propTypes: {
        modal: React.PropTypes.shape({
            id: React.PropTypes.string.isRequired,
            queryUrl: React.PropTypes.string.isRequired,
            type: React.PropTypes.string.isRequired,
            input: React.PropTypes.object.isRequired
        })
    },

    getInitialState: function() {
        return {
            modal: {
                selection: this.props.selection,
                open: false,
                addToSelection: this.addToSelection,
                removeFromSelection: this.removeFromSelection,
                handleSave: this.handleSave,
                toggleModal: this.toggleModal
            }
        };
    },

    addToSelection: function(selected) {
        this.setState({
            modal: React.addons.update(
                this.state.modal,
                {
                    selection: {
                        $push: [selected]
                    }
                }
            )
        });
    },

    removeFromSelection: function(index) {
        this.setState({
            modal: React.addons.update(
                this.state.modal,
                {
                    selection: {
                        $splice: [[index, 1]]
                    }
                }
            )
        });
    },

    toggleModal: function() {
        this.setState({
            modal: React.addons.update(
                this.state.modal,
                {
                    open: {
                        $set: !this.state.modal.open
                    }
                }
            )
        });
    },
}
