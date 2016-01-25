var Reveal = React.createClass({
    propTypes: {
        url: React.PropTypes.string.isRequired
    },

    getInitialState: function() {
        return {
            value: '',
            results: [],
            selection: []
        };
    },

    getDefaultProps: function() {
        return {
            minLength: 3
        }
    },

    handleChange: function(event) {
        var query = event.target.value;
        this.setState({ value: query });
        this.getResults(query);
    },

    getId: function(el) {
        return parseInt(el.getAttribute('data-id'));
    },

    handleAdd: function(event) {
        var id = this.getId(event.target.closest('.result'));
        this.setState({
            selection: this.state.selection.concat(
                this.state.results.filter(function(result) {
                    return result.id === id;
                })[0]
            )
        });
    },

    handleRemove: function(id) {
        this.setState({
            selection: this.state.selection.filter(function(selected) {
                return selected.id !== id;
            })
        });
    },

    handleSave: function(event) {
        var event = new CustomEvent('selection-updated', { detail: this.state.selection });
        document.querySelector('.multiselect').dispatchEvent(event);
    },

    getResults: function(query) {
        if (query.length >= this.props.minLength) {
            $.getJSON(this.props.url + "/?gravatar=true&q=" + query, function(data) {
                this.setState({ results: data.users });
            }.bind(this));
        } else {
            this.setState({ results: [] });
        }
    },

    render: function() {
        var self = this;

        var selection = this.state.selection.map(function(selected) {
            return (
                <div className='chip' data-id={selected.id} key={"selected-" + selected.id} >
                    <img src={selected.gravatar}/>
                    {selected.name}
                    <i className='fa fa-close' onClick={self.handleRemove}/>
                </div>
            );
        });

        var results = this.state.results.filter(function(result) {
            return !self.state.selection.map(function(result) {
                return result.id;
            }).includes(result.id);
        }).map(function(result) {
            return (
                <div className='result valign-wrapper' onClick={self.handleAdd} data-id={result.id} key={"result-" + result.id}>
                    <img src={result.gravatar}/>
                    <p>{result.name}</p>
                </div>
            );
        });

        return (
            <div className='reveal'>
                <nav>
                    <div className='nav-wrapper'>
                        <form>
                          <div className='input-field'>
                            <input id='search' type='search' value={this.state.value} onChange={ this.handleChange } required/>
                            <label htmlFor='search'><i className='material-icons'>search</i></label>
                            <i className='material-icons'>close</i>
                          </div>
                        </form>
                    </div>
                </nav>
                <Multiselect selection={this.state.selection} handleRemove={this.handleRemove}/>
                <div className='results-container'>
                    {results}
                </div>
                <div className='card-reveal-controls'>
                  <a className='btn-floating btn-large waves-effect waves-light card-title cancel'><i className='material-icons'>close</i></a>
                  <a className='btn-floating btn-large waves-effect waves-light card-title' onClick={this.handleSave}><i className='material-icons'>send</i></a>
                </div>
            </div>
        );
    }
});
