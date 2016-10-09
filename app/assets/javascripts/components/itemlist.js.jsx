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
                            [field]: {$set: value}
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
        var item = this.state.modal.selection[index];
        $.ajax({
            method: 'PATCH',
            data: JSON.stringify({
                grocery_id: this.props.grocery.id,
                id: item.id,
                item: {
                    groceries_items_attributes: {
                        id: item.grocery_item_id,
                        quantity: item.quantity,
                        price: item.price,
                        units: item.units
                    }
                }
            }),
            dataType: 'json',
            contentType: 'application/json',
            url: item.url
        }).done(function(response) {
            let {
                previous_item_values,
                updated_item_values
            } = response.data

            this.setState(
                React.addons.update(
                    this.state,
                    {
                        modal: {
                            selection: {
                                [index]: {
                                    $merge: updated_item_values
                                }
                            }
                        },
                        total: {
                            $set: this.state.total + updated_item_values.price - previous_item_values.price
                        }
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

        // Timeout is used for transition sliding animation on removal
        setTimeout(function() {
            this.setState({
                total: this.state.total - item.price,
                modal: updatedModal
            }, function() {
                $('.collection-item').css('transform', 'none');
            }.bind(this));
        }.bind(this), 90);
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
                    items: selection.map(function(item) {
                        return {
                            name: item.name,
                            id: item.id,
                            quantity: item.quantity,
                            price: item.price,
                            units: item.units
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
                                $set: response.data.items
                            },
                            loading: {
                                $set: false
                            }
                        },
                        total: {
                            $set: response.data.total
                        }
                    }
                )
            );
        });
    },

    componentDidMount: function() {
        var _this = this;

        this.setState({paginationAlwaysShow: true});
        $(document).ready(function() {
            _this.reloadItems();
            $('.item-list').on('removeItem', '.dismissable', function(e) {
                _this.handleRemove(e);
            });
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

        if (prevState.modal.selection.length != this.state.modal.selection.length) {
            this.updatePagination(this.state.modal.selection.length);
        }
    },

    renderItems: function() {
        var displayItems = this.itemsForPage(
            this.state.modal.selection.reduce(function(acc, item, index) {
                var requester = this.state.users.filter(function(user) {
                    return user.id === item.requester;
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
            return (
                <li key={'item-' + data.index}
                    ref={'item-' + data.index}
                    data-index={data.index}
                    className='collection-item dismissable'>
                    <div ref={'collapsible-' + data.index} className='collapsible-header'>
                        <img src={data.requester.image} />
                        <p>
                            <strong>{data.requester.name}</strong> wants <strong>{data.item.display_name}</strong>
                        </p>
                        <div className='badge price'>
                            ${parseFloat(data.item.price).toFixed(2)}
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
                            <div className="col s3">
                                <label htmlFor={priceId}>Price</label>
                                <input
                                    onChange={this.handleItemFieldChange}
                                    id={priceId}
                                    type="number"
                                    data-field="price"
                                    step="any"
                                    value={data.item.price} />
                            </div>
                            <div className="col l3 s3">
                                <label htmlFor={unitsId}>Units</label>
                                <input
                                    className='autocomplete'
                                    onChange={this.handleItemFieldChange}
                                    id={unitsId}
                                    type="text"
                                    data-field="units"
                                    value={data.item.units} />
                            </div>
                            <a
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
            <ul className='collection collapsible popout data-collapsible="accordion"'>
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
                        <a
                            onClick={this.toggleModalAndLoading}
                            href={"#" + this.props.modal.id}
                            className="btn-floating">
                            <i className="material-icons">add</i>
                        </a>
                    </div>
                </div>
                <Modal
                    {...this.state.modal}
                    {...this.props.modal}/>
            </div>
        );
    }
});
