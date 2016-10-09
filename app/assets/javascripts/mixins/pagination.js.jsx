var Pagination = {
    getInitialState: function() {
        return {
            pageSize: 4,
            pageNumber: 0,
            paginationTotal: 0,
            paginationAlwaysShow: false
        };
    },

    componentDidUpdate: function(prevProps, prevState) {
        if (prevState.paginationTotal !== this.state.paginationTotal) {
            const lastPage = this.lastPage();
            if (this.state.pageNumber >= lastPage) {
                this.setState({ pageNumber: lastPage })
            }
        }
    },

    itemsForPage: function(items) {
        return items.splice(this.state.pageSize * this.state.pageNumber, this.state.pageSize);
    },

    handlePageChange: function(e) {
        this.pageChange(parseInt(e.target.getAttribute('data-index')));
    },

    pageChange: function(index) {
        this.setState({pageNumber: index});
    },

    updatePagination: function(total) {
        this.setState({paginationTotal: total});
    },

    renderPagination: function() {
        var pages = [];
        var lastPage = this.lastPage();

        if (lastPage === 0 && !this.state.paginationAlwaysShow)
            return;

        for (var pageNumber = 0; pageNumber <= lastPage; pageNumber++) {
            pages.push(
                <li
                    key={pageNumber}
                    className={this.state.pageNumber === pageNumber ? 'active' : ''}>
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

    lastPage: function() {
        return Math.floor((this.state.paginationTotal - 1) / this.state.pageSize);
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
    }
};
