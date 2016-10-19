var Payments = React.createClass({
    mixins: [Pagination],

    propTypes: {
        payments: React.PropTypes.array.isRequired
    },

    getInitialState: function() {
        return {
            payments: this.props.payments,
        }
    },

    componentWillMount: function() {
        this.setState({pageSize: 10})
    },

    componentDidMount: function() {
        this.updatePagination(this.state.payments.length);
        $(document).ready(function() {
            $('.collapsible').collapsible({ accordion: false });
        })
    },

    renderLabel: function(value, label, id) {
        return (
            <div className='label-content'>
                <label htmlFor={id}>{label}</label>
                <p id={id}>
                    {value}
                </p>
            </div>
        );
    },

    renderItems: (payment) => {
        var groceryItems = payment.items.map((item, index) => {
            let identifier = `grocery-${payment.id}-item-${index}`;
            return (
                <Chip
                    key={identifier}
                    index={index}
                    label={`${item.name} - ${item.price}`}
                />
            );
        });

        return (
            <div className='items'>
                <h2>Items</h2>
                <div className='row'>
                    <div className='col l12 item-container'>
                        {groceryItems}
                    </div>
                </div>
            </div>
        )
    },

    renderPayments: function() {
        return this.itemsForPage(this.state.payments.map(function(payment, paymentIndex) {
            var date = moment(payment.date).format('dddd, MMMM Do YYYY')

            if (payment.payments) {
                var receiptContent;
                var groceryPayments = payment.payments.map(function(nestedPayment, nestedPaymentIndex) {
                    return (
                        <li
                            className='nested-payment valign-wrapper'
                            key={paymentIndex +  '-' + nestedPaymentIndex}>
                                <img src={nestedPayment.image}/>
                                <p>{nestedPayment.payer} contributed</p>
                                <div className='badge price payer'>
                                    {nestedPayment.price}
                                </div>
                        </li>
                    );
                });

                if (payment.receipt) {
                    receiptContent = (
                        <a
                            className='btn'
                            target='_blank'
                            rel='noopener'
                            href={payment.receipt}>
                            View Receipt
                        </a>
                    );
                }

                var collapsibleBody = (
                    <div className='collapsible-body'>
                        <ul>
                            {groceryPayments}
                        </ul>
                        <div className='row grocery-information'>
                            <div className='col l10'>
                                {payment.items.length ? this.renderItems(payment) : null}
                            </div>
                            <div className='col l2'>
                                {receiptContent}
                            </div>
                        </div>
                    </div>
                );

                return (
                    <li
                        className='grocery-payment'
                        key={paymentIndex}>
                        <div className='collapsible-header'>
                            <div className='left-content'>
                                <i className='fa fa-shopping-basket'/>
                                {this.renderLabel(payment.name, 'Name:', 'payment-' + paymentIndex)}
                            </div>
                            <div className='right-content'>
                                {this.renderLabel(date, 'Date:', 'date-' + paymentIndex)}
                            </div>
                            <div className='badge price'>
                                {payment.total}
                            </div>
                        </div>
                        {collapsibleBody}
                    </li>
                );
            } else {
                if (payment.reason) {
                    var reasonContent = this.renderLabel(payment.reason, 'Reason:', 'reason-' + paymentIndex);
                }
                return (
                    <li
                        className='user-payment'
                        key={paymentIndex}>
                        <div className='collapsible-header'>
                            <div className='left-content'>
                                <i className='fa fa-user'/>
                                <img src={payment.payer.image}/>
                                <p>{payment.payer.name}</p>
                                <i className='fa fa-long-arrow-right'/>
                                <img src={payment.payee.image}/>
                                <p>{payment.payee.name}</p>
                            </div>
                            <div className='right-content'>
                                {this.renderLabel(date, 'Date:', 'date-' + paymentIndex)}
                                {reasonContent}
                            </div>
                            <div className='badge price'>
                                {payment.total}
                            </div>
                        </div>
                    </li>
                );
            }
        }.bind(this)));
    },

    render: function() {
        if (this.state.payments.length !== 0) {
            var paymentContent = (
                <div className='card-content full-width'>
                    <ul
                        data-collapsible='accordion'
                        className='collapsible payments'>
                        {this.renderPayments()}
                    </ul>
                    {this.renderPagination()}
                </div>
            );
        } else {
            var paymentContent = (
                <div className='card-content no-payments'>
                    <p>Your Kit does not currently have any payments.</p>
                    <i className='fa fa-folder-open-o'/>
                </div>
            );
        }
        return (
            <div className='card payments-card'>
                {paymentContent}
            </div>
        );
    }
});
