var Multiselect = React.createClass({
    propTypes: {
        title: React.PropTypes.string,
        button: React.PropTypes.string,
        selection: React.PropTypes.array,
        removeSelection: React.PropTypes.func,
        hiddenField: React.PropTypes.string,
        modal: React.PropTypes.string,
        backspaceTarget: React.PropTypes.number
    },

    getInitialState: function() {
        return {
            selection: []
        };
    },

    handleRemove: function(event) {
        this.props.removeSelection(parseInt(event.target.closest('.chip').getAttribute('data-id')));
    },

    render: function() {
        var button, title, remove;
        if (this.props.modal) {
            button = <a href={this.props.modal} className='waves effect waves light btn secondary modal-trigger'>
                        {this.props.button}
                    </a>;
        }

        if (this.props.title) {
            title = <h3>{this.props.title}</h3>;
        }

        if (this.props.removeSelection) {
            remove = <i className='fa fa-close' onClick={this.handleRemove}/>;
        }

        var selection = this.state.selection.map(function(selected, index) {
            return (
                <div
                    className={this.props.backspaceTarget === index ? 'chip targetted' : 'chip'}
                    data-id={index}
                    key={'selection-' + index} >
                    <img src={selected.gravatar}/>
                    {selected.name}
                    {remove}
                </div>
            );
        }.bind(this));

        return (
            <div className='multiselect' ref='root'>
                {title}
                <div className='selection-container valign-wrapper'>
                    {selection}
                </div>
                {button}
            </div>
        );
    },

    componentDidMount: function() {
        if (!this.props.removeSelection) {
            this.refs.root.addEventListener('selection-updated', function(event) {
                this.setState({ selection: event.detail });
            }.bind(this));
        }
    },

    componentDidUpdate: function(prevProps, prevState) {
        if (this.props.selection !== prevProps.selection) {
            this.setState({ selection: this.props.selection });
        }
        if (this.state.selection !== prevState.selection) {
            if (this.props.hiddenField) {
                document.querySelector(this.props.hiddenField).value = this.state.selection.map(function(selected) {
                    return selected.id
                }).join(',');
            }
        }
    }
});
