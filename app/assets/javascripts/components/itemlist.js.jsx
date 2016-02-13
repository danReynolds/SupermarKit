var ItemList = React.createClass({

    propTypes: {
        itemsUrl: React.PropTypes.string.isRequired,
        usersUrl: React.PropTypes.string.isRequired
    },

    getInitialState: function() {
        return {
            items: [],
            users: []
        }
    },

    componentDidMount: function() {
        var self = this;
        $.getJSON(self.props.usersUrl, function(users) {
            return users;
        }).then(function(users) {
            $.getJSON(self.props.itemsUrl, function(items) {
                self.setState({
                    users: users,
                    items: items
                });
            })
        });

        $(document).ready(function() {
            $('.collapsible').collapsible({
                accordion: false
            });
        });

    },

    componentDidUpdate: function() {
        Materialize.initializeDismissable();
    },

    render: function() {
        var image, requester;
        var items = this.state.items.map(function(item, index) {
            image = <img src={item.gravatar}/>;
            return (
                <li key={'item-' + index} className='collection-item dismissable'>
                    <div className='collapsible-header'>
                        {image}
                        <p>
                            <strong>Dan</strong> wants <strong>{item.quantity_formatted}</strong>
                        </p>
                    </div>
                    <div className='collapsible-body'>
                        <p>This is a test of the collapsible body.</p>
                    </div>
                </li>
            );
        }.bind(this));

        return (
            <div className='item-list'>
                <div className='card'>
                    <div className='card-content'>
                        <ul className='collection collapsible popout data-collapsible="accordion'>
                            {items}
                        </ul>
                    </div>
                </div>
            </div>
        );
    }
});
