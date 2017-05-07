class PaymentList extends React.Component {
    constructor(props) {
        super(props);

        this.state = {
            payments: []
        }
    }

    renderPayments() {

    }

    render() {
        return (
            <div className='payment-list'>
                <ul>
                    <li>
                        <div>From</div>
                    </li>
                </ul>
            </div>
        )
    }
}
