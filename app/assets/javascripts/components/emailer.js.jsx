var Emailer = React.createClass({
    mixins: [ModalContainer],

    render: function() {
        return (
            <div className='card emailer'>
                <div className='card-content full-width dark'>
                    <div className='card-header'>
                        <h3>Email Members</h3>
                    </div>
                    <div className='email-users'>
                        <Multiselect
                            buttonText={this.props.buttonText}
                            toggleModal={this.toggleModal}
                            selection={this.state.modal.selection}/>
                    </div>
                    <div className='row'>
                        <div className="input-field col s12">
                            <textarea
                                placeholder="Message for Kit members"
                                id="textarea1"
                                className="materialize-textarea">
                            </textarea>
                        </div>
                    </div>
                    <div className='card-action'>
                        <a
                            onClick={this.handleSave}
                            className='waves-effect waves-light btn'>
                            <i className='material-icons left'>send</i>
                            Send
                        </a>
                    </div>
                </div>

                <Modal
                    {...this.state.modal}
                    {...this.props.modal}/>
            </div>
        )
    },

    handleSave: function() {
        $.ajax({
            method: 'POST',
            data: JSON.stringify({
                grocery: {
                    email: this.state.modal.selection.map(function(item) {
                        return {
                            user_id: item.id
                        }
                    })
                }
            }),
            contentType: 'application/json',
            url: this.props.url
        });
    }
});
