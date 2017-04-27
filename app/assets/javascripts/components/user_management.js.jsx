var UserManagement = React.createClass({
    mixins: [Pagination],

    propTypes: {
        url: React.PropTypes.string.isRequired,
        modal: React.PropTypes.string.isRequired,
        users: React.PropTypes.object.isRequired
    },

    getInitialState: function() {
        return {
            loading: false,
            editing: false,
            paymentAmount: 0,
            paymentReason: '',
            users: []
        }
    },

    componentWillMount: function() {
        this.reloadUsers();
    },

    reloadUsers: function() {
        const { users: { get_url } } = this.props;
        let loadingTimer = setTimeout(() => {
            this.setState({ loading: true });
        }, 100);

        $.getJSON(get_url, (data) => {
            clearTimeout(loadingTimer);
            this.setState({ loading: false, users: data });
        });
    },

    modalTrigger: function(index) {
        $(this.props.modal).openModal({
            complete: function() {
                this.setState({
                    editing: false,
                    paymentAmount: 0,
                    payeeIndex: null,
                    paymentReason: ''
                });
            }.bind(this)
        });
        this.setState({ editing: true, payeeIndex: index });
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

    componentDidUpdate: function(_, prevState) {
        const { users } = this.state;
        const { users: oldUsers } = prevState;

        if (oldUsers.length !== users.length) {
            this.updatePagination(users.length);
        }
    },

    handlePayment: function(e) {
        this.setState({paymentAmount: parseFloat(e.target.value ? e.target.value : 0)});
    },

    handleReason: function(e) {
        this.setState({paymentReason: e.target.value});
    },

    handleSubmit: function(e) {
        e.preventDefault();
        let loadingTimer;
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
        }).done(function() {
            this.reloadUsers();
        }.bind(this));
    },

    renderContent: function() {
        const { loading } = this.state;

        if (loading) {
            return <Loader />;
        }

        return (
            <div>
                <h3>Kit members</h3>
                {this.renderUserItems()}
                {this.renderPagination()}
            </div>
        )
    },

    render: function() {
        let modalContent;
        const { editing } = this.state;

        if (editing) {
            const payee = React.addons.update(
                this.state.users[this.state.payeeIndex],
                { balance: { $set: this.state.users[this.state.payeeIndex].balance + this.state.paymentAmount } }
            );

            const payer = React.addons.update(
                this.state.users[0],
                { balance: { $set: this.state.users[0].balance - this.state.paymentAmount } }
            );

            modalContent = (
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
            );
        }

        return (
            <div id='test' className='user-management'>
                <div className='card'>
                    <div className='card-content'>
                        {this.renderContent()}
                    </div>
                </div>
                <form onSubmit={this.handleSubmit}>
                    <div id='pay-modal' className='modal'>
                        {modalContent}
                        <div className='modal-footer'>
                            <div
                                className='modal-action modal-close btn cancel'>
                                Cancel
                            </div>
                            <input
                                type='submit'
                                value='Confirm'
                                className='modal-action modal-close btn'
                            />
                        </div>
                    </div>
                </form>
            </div>
        )
    }
});
