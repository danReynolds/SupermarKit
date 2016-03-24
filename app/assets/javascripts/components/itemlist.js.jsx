var ItemList = React.createClass({
    mixins: [RevealMixin],
    propTypes: {
        users: React.PropTypes.array.isRequired,
        grocery: React.PropTypes.object.isRequired,
        items: React.PropTypes.object.isRequired,
        pageSize: React.PropTypes.number
    },

    getDefaultProps: function() {
        return {
            pageSize: 5
        }
    },

    getInitialState: function() {
        return {
            users: this.props.users,
            pageNumber: 0
        }
    },

    getSelectedIndex: function(e) {
        return parseInt($(e.target).closest('.collection-item').attr('data-index'));
    },

    handleItemFieldChange: function(e) {
        var index = this.getSelectedIndex(e);
        var field = e.target.getAttribute('data-field');
        var value = parseFloat(e.target.value);

        this.setState({
            selection: React.addons.update(
                this.state.selection,
                {
                    [index]: {
                        [field]: {$set: Number.isFinite(value) ? value : null}
                    }
                }
            )
        });
    },

    handleItemUpdate: function(e) {
        var index = this.getSelectedIndex(e);
        var selected = this.state.selection[index];
        $.ajax({
            method: 'PATCH',
            data: JSON.stringify({
                grocery_id: this.props.grocery.id,
                id: selected.id,
                item: {
                    groceries_items_attributes: {
                        id: selected.grocery_item_id,
                        quantity: selected.quantity,
                        price: selected.price
                    }
                }
            }),
            dataType: 'json',
            contentType: 'application/json',
            url: selected.url
        }).done(function(item) {
            this.setState({
                selection: React.addons.update(
                    this.state.selection,
                    {
                        [index]: {$set: item.data}
                    }
                )
            });
        }.bind(this));
    },

    handleRemove: function(e) {
        this.removeItem(this.getSelectedIndex(e));
    },

    removeItem: function(index) {
        var updatedSelection = React.addons.update(this.state.selection, {$splice: [[index, 1]]});
        this.saveSelection(updatedSelection);
        setTimeout(function(){
            this.setState({ selection: updatedSelection }, function() {
                $('.collection-item').css('transform', 'none');
            }.bind(this));
        }.bind(this), 100);
    },

    handleSave: function() {
        this.saveSelection(this.state.selection);
    },

    handlePageChange: function(e) {
        this.pageChange(parseInt(e.target.getAttribute('data-index')));
    },

    pageChange: function(index) {
        this.setState({pageNumber: index});
    },

    lastPage: function() {
        return Math.floor((this.state.selection.length - 1) / this.props.pageSize);
    },

    incrementPage: function() {
        this.pageChange(
            this.state.pageNumber === this.lastPage() ? 0 : this.state.pageNumber + 1
        );
    },

    decrementPage: function() {
        this.pageChange(
            this.state.pageNumber === 0 ? this.lastPage() : this.state.pageNumber - 1
        );
    },

    saveSelection: function(selection) {
        $.ajax({
            method: 'PATCH',
            data: JSON.stringify({
                grocery: {
                    items: selection.map(function(item) {
                        return {
                            name: item.name,
                            id: item.id,
                            quantity: item.quantity,
                            price: item.price
                        }
                    })
                }
            }),
            contentType: 'application/json',
            url: this.props.grocery.url
        });
    },

    reloadItems: function() {
        $.getJSON(this.props.items.url, function(selection) {
            this.setState({ selection: selection });
            $('.collapsible').collapsible({ accordion: false });
            Materialize.initializeDismissable();
        }.bind(this));
    },

    componentDidMount: function() {
        var self = this;
        $(document).ready(function() {
            self.reloadItems();
            $('.item-list').on('removeItem', '.dismissable', function(e) {
                self.handleRemove(e);
            });
        });
    },

    componentDidUpdate: function(prevProps, prevState) {
        if (!this.state.modalOpen && prevState.modalOpen) {
            this.reloadItems();
        }
    },

    renderItems: function() {
        var displayItems = this.state.selection.reduce(function(acc, item, index) {
            var requester = this.state.users.filter(function(user) {
                return user.id === item.requester;
            })[0];

            if (requester) {
                acc.push({item: item, requester: requester});
            }
            return acc;
        }.bind(this), []).splice(this.props.pageSize * this.state.pageNumber, this.props.pageSize);

        var content = displayItems.map(function(data, index) {
            var quantityId = "quantity-" + index;
            var priceId = "price-" + index;
            return (
                <li key={'item-' + index}
                    ref={'item-' + index}
                    data-index={index}
                    className='collection-item dismissable'>
                    <div className='collapsible-header'>
                        <img src={data.requester.gravatar} />
                        <p>
                            <strong>{data.requester.name}</strong> wants <strong>{data.item.quantity_formatted}</strong>
                        </p>
                        <div className='price'>
                            {data.item.total_price_formatted}
                        </div>
                    </div>
                    <div  className='collapsible-body'>
                        <div className="valign-wrapper">
                            <div className="col l3 s3">
                                <label htmlFor={quantityId}>Quantity</label>
                                <input
                                    onChange={this.handleItemFieldChange}
                                    id={quantityId}
                                    data-field="quantity"
                                    type="number"
                                    step="any"
                                    value={data.item.quantity} />
                            </div>
                            <div className="col s4">
                                <label htmlFor={priceId}>Price per item</label>
                                <input
                                    onChange={this.handleItemFieldChange}
                                    id={priceId}
                                    type="number"
                                    data-field="price"
                                    step="any"
                                    value={data.item.price} />
                            </div>
                            <a
                                className='waves-effect waves-light btn'
                                onClick={this.handleItemUpdate}>
                                Update
                            </a>
                        </div>
                    </div>
                    <div
                        onClick={this.handleRemove}
                        className="remove">
                        <i className='fa fa-close'/>
                    </div>
                </li>
            );
        }.bind(this));

        return (
            <ul className='collection collapsible popout data-collapsible="accordion'>
                {content}
                {this.renderPagination()}
            </ul>
        );
    },

    renderNoContent: function() {
        return <div className="no-items">
                   <i className='fa fa-shopping-basket'/>
                   <h3>Your grocery list is empty.</h3>
               </div>;
    },

    renderPagination: function() {
        var pages = [];
        var pageLength = this.lastPage();
        for (var pageNumber = 0; pageNumber <= pageLength; pageNumber++) {
            pages.push(
                <li
                    key={pageNumber}
                    className={this.state.pageNumber == pageNumber ? "active" : ""}>
                    <a
                        data-index={pageNumber}
                        onClick={this.handlePageChange}
                        href="#!">
                        {pageNumber + 1}
                    </a>
                </li>
            );
        }
        return (
            <ul className='pagination'>
                <li>
                    <a href="#!" onClick={this.decrementPage}>
                        <i className="material-icons">chevron_left</i>
                    </a>
                </li>
                {pages}
                <li>
                    <a href="#!" onClick={this.incrementPage}>
                        <i className="material-icons">chevron_right</i>
                    </a>
                </li>
            </ul>
        );
    },

    render: function() {
        var content, pagination;
        if (this.state.modalOpen || !this.state.selection) {
            content = <Loader />
        } else {
            content = this.state.selection.length ? this.renderItems() : this.renderNoContent();
        }

        return (
            <div className='item-list'>
                <div className='card'>
                    <div className='card-content'>
                        <div className='card-header'>
                            <h3>Groceries for {this.props.grocery.name}</h3>
                        </div>
                        {content}
                        {pagination}
                        <a
                            onClick={this.toggleModal}
                            href={"#" + this.props.modal.id}
                            className="btn-floating btn-large waves-effect waves-light">
                            <i className="material-icons">add</i>
                        </a>
                    </div>
                </div>
                <Reveal
                    selection={this.state.selection}
                    modalOpen={this.state.modalOpen}
                    toggleModal={this.toggleModal}
                    handleSave={this.handleSave}
                    addToSelection={this.addToSelection}
                    removeFromSelection={this.removeFromSelection}
                    {...this.props.modal} />
            </div>
        );
    }
});
