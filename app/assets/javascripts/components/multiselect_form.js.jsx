var MultiselectForm = React.createClass({
    mixins: [ModalContainer],

    propTypes: {
        title: React.PropTypes.string,
        button: React.PropTypes.string,
        users: React.PropTypes.array,
        formElement: React.PropTypes.string.isRequired,
        modal: React.PropTypes.object.isRequired
    },

    handleSave: function() {
        document.getElementById(this.props.formElement).value = this.state.modal.selection.map(function(selected) {
            return selected.id;
        }).join(',');
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
                        chipType={this.props.modal.chipType}
                        selection={this.state.modal.selection}/>
                    <a
                        onClick={this.toggleModal}
                        href={"#" + this.props.modal.id}
                        className="btn-floating btn-large modal-trigger waves-effect waves-light">
                        <i className="material-icons">add</i>
                    </a>
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
