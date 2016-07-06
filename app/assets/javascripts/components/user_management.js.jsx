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
            users: this.props.users
        }
    },

    modalTrigger: function(index) {
        $(this.props.modal).openModal({
            complete: function() {
                this.setState({
                    paymentAmount: 0,
                    payeeIndex: 0
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
        this.updatePaginationTotal(this.state.users.length);
    },

    handlePayment: function(e) {
        this.setState({paymentAmount: parseFloat(e.target.value ? e.target.value : 0)});
    },

    handleSubmit: function() {
        $.ajax({
            method: 'PATCH',
            url: this.props.url,
            contentType: 'application/json',
            data: JSON.stringify({
                user_group: {
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
                            onClick={this.handleSubmit}
                            className='modal-action modal-close waves-effect waves-green btn'>
                            Confirm
                        </a>
                    </div>
                </div>
            </div>
        )
    }
});
