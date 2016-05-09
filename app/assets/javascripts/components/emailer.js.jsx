var Emailer = React.createClass({
    mixins: [ModalContainer],

    getInitialState: function() {
        return {
            message: ''
        }
    },

    handleChange: function(e) {
        this.setState({
            message: e.target.value,
            delivery: false
        });
    },

    render: function() {
        var content;
        if (this.state.modal.open || this.state.delivery) {
            content = <Loader />;
        } else {
            content = (
                <div>
                    <div className='email-users'>
                        <Multiselect
                            buttonText={this.props.buttonText}
                            toggleModal={this.toggleModal}
                            selection={this.state.modal.selection}/>
                    </div>
                    <div className='row'>
                        <div className="input-field col s12">
                            <textarea
                                value={this.state.message}
                                onChange={this.handleChange}
                                placeholder="Message for Kit members"
                                id="textarea1"
                                className="materialize-textarea">
                            </textarea>
                        </div>
                    </div>
                    <div className='card-action'>
                        <a
                            onClick={this.deliverEmail}
                            className='waves-effect waves-light btn'>
                            <i className='material-icons left'>send</i>
                            Send
                        </a>
                    </div>
                </div>
            );
        }
        return (
            <div className='card emailer'>
                <div className='card-content full-width dark'>
                    <div className='card-header'>
                        <h3>Email Members</h3>
                    </div>
                    {content}
                </div>
                <Modal
                    {...this.state.modal}
                    {...this.props.modal}/>
            </div>
        );
    },

    deliverEmail: function() {
        this.setState({
            delivery: true
        });
        $.ajax({
            method: 'POST',
            data: JSON.stringify({
                grocery: {
                    email: {
                        user_ids: this.state.modal.selection.map(function(user) {
                            return user.id;
                        }),
                        message: this.state.message
                    }
                }
            }),
            contentType: 'application/json',
            url: this.props.url
        }).done(function() {
            setTimeout(function() {
                this.setState({
                    delivery: false,
                    message: ''
                });
                Materialize.toast('Your email has been sent!', 2000);
            }.bind(this), 500);
        }.bind(this));
    },

    handleSave: function() {
        this.toggleModal();
    }
});
