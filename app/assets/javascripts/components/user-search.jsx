var UserSearch = React.createClass({
    mixins: [ModalContainer],

    propTypes: {
        title: React.PropTypes.string,
        button: React.PropTypes.string,
        modal: React.PropTypes.object.isRequired,
        onSelectionChange: React.PropTypes.func,
    },

    handleSave: function(modalSelection) {
        this.onSelectionChange(modalSelection, this.toggleModalAndLoading);
    },

    render: function() {
        if (this.props.title) {
            var title = <h3>{this.props.title}</h3>;
        }

        return (
            <div className='multi-select-form'>
                <div>
                    {title}
                    <Multiselect
                        expandable={false}
                        toggleModal={this.toggleModal}
                        buttonText={this.props.buttonText}
                        selection={this.props.modal.selection}/>
                </div>
                <div>
                    <Modal
                        {...this.state.modal}
                        {...this.props.modal}/>
                </div>
            </div>
        );
    }
});
