var ItemList = React.createClass({
    propTypes: {
        users: React.PropTypes.array.isRequired,
        grocery: React.PropTypes.object.isRequired,
        reveal: React.PropTypes.object.isRequired
    },

    getInitialState: function() {
        return {
            items: [],
            users: []
        }
    },

    handleRemove: function(index) {
        $.ajax({
            method: 'PATCH',
            url: '/items/' + this.state.items[index].id + '/remove/?grocery_id=' + this.props.grocery.id
        }).done(function() {
            this.setState({
                items: React.addons.update(this.state.items, {$splice: [[index, 1]]})
            });
        }.bind(this));
    },

    componentDidMount: function() {
        $(document).ready(function() {
            $('.collapsible').collapsible({
                accordion: false
            });
        });
    },

    componentDidUpdate: function() {
        Materialize.initializeDismissable();
        $('.dismissable').on('remove', function(e) {
            this.handleRemove(parseInt(e.target.getAttribute('data-index')));
        }.bind(this));
    },

    render: function() {
        var requester, noItems;

        if (this.state.items.length === 0) {
            noItems = <div className="no-items">
                          <i className='fa fa-shopping-basket'/>
                          <h2>Your grocery list is empty.</h2>
                      </div>
        }
        var items = this.state.items.map(function(item, index) {
            requester = this.state.users.filter(function(user) {
                return user.id == item.requester;
            })[0];

            return (
                <li key={'item-' + index}
                    data-index={index}
                    className='collection-item dismissable'>
                    <div className='collapsible-header'>
                        <img src={requester.gravatar}/>
                        <p>
                            <strong>{requester.name}</strong> wants <strong>{item.quantity_formatted}</strong>
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
                        <div className='card-header'>
                            <h3>Groceries for {this.props.grocery.name}</h3>
                        </div>
                        <ul className='collection collapsible popout data-collapsible="accordion'>
                            {noItems}
                            {items}
                        </ul>
                        <a
                            href={"#" + this.props.reveal.modal}
                            className="btn-floating btn-large waves-effect waves-light modal-trigger">
                            <i className="material-icons">add</i>
                        </a>
                    </div>
                </div>
                <div id={this.props.reveal.modal} className='modal bottom-sheet'>
                    <div className='modal-content'>
                        <Reveal {...this.props.reveal} />
                    </div>
                </div>
            </div>
        );
    }
});
