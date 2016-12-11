var ItemList = React.createClass({
    mixins: [ModalContainer, Pagination],
    propTypes: {
        users: React.PropTypes.array.isRequired,
        grocery: React.PropTypes.object.isRequired,
        items: React.PropTypes.object.isRequired,
        recipes: React.PropTypes.array
    },

    getInitialState: function() {
        return {
            users: this.props.users,
            total: 0
        };
    },

    getSelectedIndex: function(e) {
        return parseInt($(e.target).closest('.collection-item').attr('data-index'));
    },

    handleItemFieldChange: function(e) {
        var index = this.getSelectedIndex(e);
        var field = e.target.getAttribute('data-field');
        var target = e.target;
        var value =  target.value;

        if (target.type === 'number') {
            value = parseFloat(value);
            if (!Number.isFinite(value)) {
                value = null;
            }
        }

        this.setState({
            modal: React.addons.update(
                this.state.modal,
                {
                    selection: {
                        [index]: {
                            grocery_item: {
                                [field]: {$set: value}
                            }
                        }
                    }
                }
            )
        });
    },

    handleItemUpdate: function(e) {
        var index = this.getSelectedIndex(e);

        // Close collapsible on update button clicked
        ReactDOM.findDOMNode(this.refs['collapsible-' + index]).click();

        this.updateItem(index);
    },

    updateItem: function(index) {
        const item = this.state.modal.selection[index];
        const { grocery_item } = item;
        $.ajax({
            method: 'PATCH',
            data: JSON.stringify({
                grocery_id: this.props.grocery.id,
                id: item.id,
                item: {
                    groceries_items_attributes: {
                        id: grocery_item.id,
                        quantity: grocery_item.quantity,
                        price: grocery_item.price,
                        units: grocery_item.units
                    }
                }
            }),
            dataType: 'json',
            contentType: 'application/json',
            url: item.links.self
        }).done(function(response) {
            let {
                grocery_item,
                updated_grocery_item,
            } = response;
            this.setState(
                React.addons.update(
                    this.state,
                    {
                        modal: {
                            selection: {
                                [index]: {
                                    grocery_item: {
                                        $merge: updated_grocery_item
                                    }
                                }
                            }
                        },
                    }
                )
            );
        }.bind(this));
    },

    handleRemove: function(e) {
        this.removeItem(this.getSelectedIndex(e));
    },

    removeItem: function(index) {
        var item = this.state.modal.selection[index];
        var updatedModal = React.addons.update(
            this.state.modal,
            {
                selection: {$splice: [[index, 1]]}
            }
        );
        this.saveSelection(updatedModal.selection);
        this.setState({
            total: this.state.total - item.price,
            modal: updatedModal
        });
    },

    handleSave: function(modalSelection) {
        this.toggleModal();
        this.saveSelection(modalSelection, this.reloadItems);
    },

    initializeAutocomplete: function(unit_types) {
        var inputs = $('input.autocomplete');
        inputs.autocomplete({data: unit_types});
        inputs.on('change', this.handleItemFieldChange);
    },

    saveSelection: function(selection, callback) {
        $.ajax({
            contentType: 'application/json',
            url: this.props.grocery.url,
            method: 'PATCH',
            data: JSON.stringify({
                grocery: {
                    items: selection.map(selected => {
                        const { grocery: { id: groceryId } } = this.props;
                        return {
                            id: selected.id,
                            name: selected.name,
                            groceries_items_attributes: selected.grocery_item || {
                                quantity: selected.quantity,
                                price: selected.price,
                                units: selected.units,
                                grocery_id: groceryId,
                                id: null,
                            },
                        }
                    })
                }
            })
        }).done(callback);
    },

    reloadItems: function() {
        var _this = this;
        if (!this.state.modal.loading) {
            this.toggleLoading();
        }
        $.getJSON(_this.props.items.url, function(response) {
            _this.setState(
                React.addons.update(
                    _this.state,
                    {
                        modal: {
                            selection: {
                                $set: response
                            },
                            loading: {
                                $set: false
                            }
                        }
                    }
                )
            );
        });
    },

    componentWillMount: function() {
        this.setState({paginationAlwaysShow: true});
        var _this = this;
        _this.reloadItems();

    },

    componentDidMount: function() {
        $('.item-list').on('removeItem', '.dismissable', (e) => {
            this.handleRemove(e);
        });
    },

    componentDidUpdate: function(prevProps, prevState) {
        const { modal } = this.state;
        if (prevProps.recipes !== this.props.recipes) {
            this.reloadItems();
        } else if (this.state.pageNumber !== prevState.pageNumber ||
            (modal.loading !== prevState.modal.loading && modal.selection.length)) {
            Materialize.initializeDismissable();
            $('.collapsible').collapsible({ accordion: false });
            this.initializeAutocomplete(this.props.items.unit_types);
        }

        if (prevState.modal.selection !== modal.selection) {
            this.setState({
                total: modal.selection.reduce((acc, selected) => {
                    const { grocery_item: { price } } = selected;
                    return acc + price;
                }, 0)
            });
        }

        if (prevState.modal.selection.length != modal.selection.length) {
            this.updatePagination(modal.selection.length);
        }
    },

    renderItems: function() {
        var displayItems = this.itemsForPage(
            this.state.modal.selection.reduce(function(acc, item, index) {
                var requester = this.state.users.filter(function(user) {
                    return user.id === item.grocery_item.requester_id;
                })[0];

                if (requester) {
                    acc.push({item: item, requester: requester, index: index});
                }
                return acc;
            }.bind(this), [])
        );

        var itemContent = displayItems.map(function(data) {
            var quantityId = "quantity-" + data.index;
            var priceId = "price-" + data.index;
            var unitsId = "units-" + data.index;
            const { item, item: { grocery_item } } = data;
            return (
                <li key={'item-' + data.index}
                    ref={'item-' + data.index}
                    data-index={data.index}
                    className='collection-item dismissable'>
                    <div ref={'collapsible-' + data.index} className='collapsible-header'>
                        <img src={data.requester.image} />
                        <p>
                            <strong>{data.requester.name}</strong> wants <strong>{grocery_item.display_name}</strong>
                        </p>
                        <div className='badge price'>
                            ${parseFloat(grocery_item.price).toFixed(2)}
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
                                    value={grocery_item.quantity} />
                            </div>
                            <div className="col s3">
                                <label htmlFor={priceId}>Price</label>
                                <input
                                    onChange={this.handleItemFieldChange}
                                    id={priceId}
                                    type="number"
                                    data-field="price"
                                    step="any"
                                    value={grocery_item.price} />
                            </div>
                            <div className="col l3 s3">
                                <label htmlFor={unitsId}>Units</label>
                                <input
                                    className='autocomplete'
                                    onChange={this.handleItemFieldChange}
                                    id={unitsId}
                                    type="text"
                                    data-field="units"
                                    value={grocery_item.units || ''} />
                            </div>
                            <a
                                data-no-turbolink
                                className='btn'
                                onClick={this.handleItemUpdate}>
                                Update
                            </a>
                        </div>
                    </div>
                    <div
                        onClick={this.handleRemove}
                        className="remove">
                        <i className='fa fa-trash'/>
                    </div>
                </li>
            );
        }.bind(this));

        return (
            <ul className='collection collapsible plain popout data-collapsible="accordion"'>
                {itemContent}
                <div className="bottom-row">
                    <span>
                        Estimated Total:
                        <div className="badge price">
                            ${this.state.total.toFixed(2)}
                        </div>
                    </span>
                </div>
                {this.renderPagination()}
            </ul>
        );
    },

    renderNoItems: function() {
        return <div className="no-items">
                   <i className='fa fa-shopping-basket'/>
                   <h3>Your grocery list is empty.</h3>
               </div>;
    },

    render: function() {
        var content, pagination;
        if (this.state.modal.loading || !this.state.modal.selection) {
            content = <Loader />
        } else {
            content = this.state.modal.selection.length ? this.renderItems() : this.renderNoItems();
        }
        return (
            <div className='item-list'>
                <div className='card'>
                    <div className='card-content full-width dark'>
                        <div className='card-header'>
                            <h3>Groceries for {this.props.grocery.name}</h3>
                            <i className='fa fa-shopping-cart'/>
                        </div>
                        {content}
                        {pagination}
                        <div
                            onClick={this.toggleModalAndLoading}
                            href={"#" + this.props.modal.id}
                            className="btn-floating">
                            <i className="material-icons">add</i>
                        </div>
                    </div>
                </div>
                <Modal
                    {...this.state.modal}
                    {...this.props.modal}/>
            </div>
        );
    }
});
