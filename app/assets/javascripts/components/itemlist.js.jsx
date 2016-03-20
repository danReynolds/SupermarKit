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

    handleRemove: function(index) {
        this.saveSelection(React.addons.update(this.state.selection, {$splice: [[index, 1]]}));
    },

    handleSave: function() {
        this.saveSelection(this.state.selection);
    },

    handlePageChange: function(e) {
        this.pageChange(e.target.getAttribute('data-index'));
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
            dataType: 'json',
            contentType: 'application/json',
            url: this.props.grocery.url
        }).done(function() {
            debugger;
            this.setState({ items: selection });
        }.bind(this));
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
            $('.item-list').on('remove', '.dismissable', function(e) {
                self.handleRemove(parseInt(e.target.getAttribute('data-index')));
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

        return displayItems.map(function(data, index) {
            return (
                <li key={'item-' + index}
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
                        <div className='collapsible-body'>
                            <p>This is a test of the collapsible body.</p>
                        </div>
                </li>
            );
        }.bind(this));
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
        for (var pageNumber = 0; pageNumber <= this.state.selection.length / this.props.pageSize; pageNumber++) {
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
            pagination = this.renderPagination();
        }

        return (
            <div className='item-list'>
                <div className='card'>
                    <div className='card-content'>
                        <div className='card-header'>
                            <h3>Groceries for {this.props.grocery.name}</h3>
                        </div>
                        <ul className='collection collapsible popout data-collapsible="accordion'>
                            {content}
                            {pagination}
                        </ul>
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
