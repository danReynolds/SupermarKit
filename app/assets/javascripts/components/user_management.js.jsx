var UserManagement = React.createClass({
    mixins: [Pagination],

    propTypes: {
        url: React.PropTypes.string.isRequired,
        modal: React.PropTypes.string.isRequired,
        users: React.PropTypes.array.isRequired
    },

    getInitialState: function() {
        return {
            payeeIndex: 0,
            paymentAmount: 0,
            paymentReason: '',
            users: this.props.users
        }
    },

    modalTrigger: function(index) {
        $(this.props.modal).openModal({
            complete: function() {
                this.setState({
                    paymentAmount: 0,
                    payeeIndex: 0,
                    paymentReason: ''
                });
            }.bind(this)
        });
        this.setState({payeeIndex: index});
    },

    renderUserItems: function() {
        return this.itemsForPage(
            this.state.users.map(function(user, index) {
                return (
                    <UserItem
                        payable={index !== 0}
                        key={user.id}
                        index={index}
                        modalTrigger={this.modalTrigger}
                        user={user} />
                );
            }.bind(this))
        );
    },

    componentDidMount: function() {
        this.updatePagination(this.state.users.length);
    },

    handlePayment: function(e) {
        this.setState({paymentAmount: parseFloat(e.target.value ? e.target.value : 0)});
    },

    handleReason: function(e) {
        this.setState({paymentReason: e.target.value});
    },

    handleSubmit: function() {
        $.ajax({
            method: 'PATCH',
            url: this.props.url,
            contentType: 'application/json',
            data: JSON.stringify({
                user_group: {
                    reason: this.state.paymentReason,
                    price: this.state.paymentAmount,
                    payee_id: this.state.users[this.state.payeeIndex].id
                }
            })
        }).done(function(response) {
            this.setState({
                users: response.data
            });
        }.bind(this));
    },

    render: function() {
        var payee = React.addons.update(
            this.state.users[this.state.payeeIndex],
            { balance: { $set: this.state.users[this.state.payeeIndex].balance + this.state.paymentAmount } }
        );

        var payer = React.addons.update(
            this.state.users[0],
            { balance: { $set: this.state.users[0].balance - this.state.paymentAmount } }
        );

        return (
            <div className='user-management'>
                <div className='card'>
                    <div className='card-content'>
                        <h3>Kit members</h3>
                        {this.renderUserItems()}
                        {this.renderPagination()}
                    </div>
                </div>
                <div id='pay-modal' className='modal'>
                    <div className='modal-content'>
                        <h4>Pay to {payee.name}</h4>
                        <div className='row'>
                            <div className='col l6'>
                                <label
                                    htmlFor='payment'>
                                    Amount
                                </label>
                                <input
                                    value={this.state.paymentAmount}
                                    onChange={this.handlePayment}
                                    id='payment'
                                    type='number'/>
                                <label
                                    htmlFor='reason'>
                                    Reason
                                </label>
                                <input
                                    id='reason'
                                    value={this.state.paymentReason}
                                    onChange={this.handleReason}
                                    className='input-field'/>

                            </div>
                            <div className='col l6'>
                                <li className='user-item'>
                                    <UserItemContent user={payer}/>
                                </li>
                                <li className='user-item'>
                                    <UserItemContent user={payee}/>
                                </li>
                            </div>
                        </div>
                    </div>
                    <div className='modal-footer'>
                        <a
                            className='modal-action modal-close btn cancel'>
                            Cancel
                        </a>
                        <a
                            onClick={this.handleSubmit}
                            className='modal-action modal-close btn'>
                            Confirm
                        </a>
                    </div>
                </div>
            </div>
        )
    }
});
