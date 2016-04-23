var Dashboard = React.createClass({
    propTypes: {
        checkout_url: React.PropTypes.string.isRequired,
        itemList: React.PropTypes.object.isRequired
    },

    render: function() {
        return (
            <div className='dashboard'>
                <ItemList
                    {...this.props.itemList}/>
                <div className='fixed-action-btn'>
                    <a className='btn-floating btn-large'>
                        <i className='large material-icons'>mode_edit</i>
                    </a>
                    <ul>
                        <li>
                            <a className='btn-floating' href={this.props.checkout_url}>
                                <i className='fa fa-shopping-basket'/>
                            </a>
                            <div className='btn-label'>Checkout</div>
                        </li>
                    </ul>
                </div>
            </div>
        );
    }
})
