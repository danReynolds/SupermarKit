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

    handleItemUpdate: function(index, fields) {
        // Close collapsible on update button clicked
        ReactDOM.findDOMNode(this.refs['collapsible-' + index]).click();
        this.updateItem(index, fields);
    },

    isEstimatedTotal: function() {
        return this.state.modal.selection.some(selected => {
            const { grocery_item: { price } } = selected;
            return price === 0 || price === null;
        });
    },

    updateItem: function(index, fields) {
        const item = this.state.modal.selection[index];
        const { grocery_item: { id } } = item;
        const { price, units, quantity } = fields;

        $.ajax({
            method: 'PATCH',
            data: JSON.stringify({
                grocery_id: this.props.grocery.id,
                id: item.id,
                item: {
                    groceries_items_attributes: {
                        id: id,
                        quantity: quantity,
                        price: price === "" ? 0 : price,
                        units: units
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
        }

        if (prevState.modal.selection !== modal.selection) {
            this.setState({
                total: modal.selection.reduce((acc, selected) => {
                    const { grocery_item: { price, estimated_price } } = selected;
                    return acc + (price || estimated_price);
                }, 0)
            });
        }

        if (prevState.modal.selection.length != modal.selection.length) {
            this.updatePagination(modal.selection.length);
        }
    },

    renderItems: function() {
        const { items: { unit_types } } = this.props;
        const estimated = this.isEstimatedTotal();
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
            const { price, estimated_price, quantity, units } = grocery_item;

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
                        <div className={`badge price ${price ? '' : 'estimated'}`}>
                            ${parseFloat(grocery_item.price || grocery_item.estimated_price).toFixed(2)}
                        </div>
                    </div>
                    <ItemListEditor
                        quantity={quantity}
                        price={price}
                        estimatedPrice={estimated_price}
                        id={data.index}
                        units={units}
                        unitTypes={unit_types}
                        getSelectedIndex={this.getSelectedIndex}
                        handleItemUpdate={this.handleItemUpdate}
                    />
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
                        {`${estimated ? 'Estimated' : ''} Total:`}
                        <div className={`badge price ${estimated ? 'estimated' : ''}`}>
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
