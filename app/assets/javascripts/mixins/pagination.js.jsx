var Pagination = {
    firstPage: 'firstPage',
    lastPage: 'lastPage',

    getInitialState: function() {
        return {
            pageSize: 4,
            pageNumber: 0,
            paginationTotal: 0,
            paginationAlwaysShow: false,
            defaultPage: this.lastPage,
        };
    },

    componentDidUpdate: function(prevProps, prevState) {
        const { state } = this;
        if (prevState.paginationTotal !== state.paginationTotal) {
            const { defaultPage, pageNumber } = this.state;
            const lastPageNumber = this.lastPageNumber();

            if (defaultPage === this.lastPage && (pageNumber > lastPageNumber
                || state.paginationTotal > prevState.paginationTotal)) {
                this.setState({ pageNumber: lastPageNumber })
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
        var lastPage = this.lastPageNumber();

        if (lastPage === 0 && !this.state.paginationAlwaysShow)
            return;

        for (var pageNumber = 0; pageNumber <= lastPage; pageNumber++) {
            pages.push(
                <li
                    key={pageNumber}
                    className={this.state.pageNumber === pageNumber ? 'active' : ''}>
                    <a
                        className='page'
                        data-no-turbolink
                        data-index={pageNumber}
                        onClick={this.handlePageChange}>
                        {pageNumber + 1}
                    </a>
                </li>
            );
        }
        return (
            <ul className='pagination'>
                <li>
                    <a data-no-turbolink onClick={this.decrementPage}>
                        <i className="material-icons">chevron_left</i>
                    </a>
                </li>
                {pages}
                <li>
                    <a data-no-turbolink onClick={this.incrementPage}>
                        <i className="material-icons">chevron_right</i>
                    </a>
                </li>
            </ul>
        );
    },

    lastPageNumber: function() {
        const { paginationTotal, pageSize } = this.state;

        if (paginationTotal === 0) {
            return 0;
        }
        return Math.floor((paginationTotal - 1) / pageSize);
    },

    incrementPage: function() {
        this.pageChange(
            this.state.pageNumber === this.lastPageNumber() ? 0 : this.state.pageNumber + 1
        );
    },

    decrementPage: function() {
        this.pageChange(
            this.state.pageNumber === 0 ? this.lastPageNumber() : this.state.pageNumber - 1
        );
    }
};
