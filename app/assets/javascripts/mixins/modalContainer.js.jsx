var ModalContainer = {
    propTypes: {
        modal: React.PropTypes.shape({
            id: React.PropTypes.string.isRequired,
            queryUrl: React.PropTypes.string.isRequired,
            resultType: React.PropTypes.string.isRequired,
            input: React.PropTypes.object.isRequired,
            addUnmatchedQuery: React.PropTypes.bool,
        })
    },

    getInitialState: function() {
        return {
            modal: {
                selection: this.props.selection || [],
                open: false,
                addToSelection: this.addToSelection,
                removeFromSelection: this.removeFromSelection,
                handleSave: this.handleSave,
                toggleLoading: this.toggleLoading,
                toggleModal: this.toggleModal,
                toggleModalAndLoading: this.toggleModalAndLoading,
                loading: false
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
                    },
                }
            )
        });
    },

    toggleLoading: function(callback) {
        this.setState({
            modal: React.addons.update(
                this.state.modal,
                {
                    loading: {
                        $set: !this.state.modal.loading
                    },
                }
            )
        }, callback);
    },

    toggleModalAndLoading: function() {
        this.setState({
            modal: React.addons.update(
                this.state.modal,
                {
                    open: {
                        $set: !this.state.modal.open
                    },
                    loading: {
                        $set: !this.state.modal.loading
                    },
                }
            )
        });
    },
}
