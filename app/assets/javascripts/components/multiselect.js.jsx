var Multiselect = React.createClass({
    propTypes: {
        selection: React.PropTypes.array,
        removeFromSelection: React.PropTypes.func,
        hiddenField: React.PropTypes.string,
        backspaceTarget: React.PropTypes.number,
        removable: React.PropTypes.bool,
        buttonText: React.PropTypes.string,
        toggleModal: React.PropTypes.func
    },

    getDefaultProps: function() {
        return {
            selection: [],
            removable: false,
            expandable: true,
        }
    },

    getInitialState: function() {
        return {
            expanded: false,
        }
    },

    handleRemove: function(event) {
        this.props.removeFromSelection(parseInt(event.target.closest('.chip').getAttribute('data-id')));
    },

    toggleExpanded: function() {
        this.setState({ expanded: !this.state.expanded });
    },

    render: function() {
        const { expanded } = this.state;
        let expandableContent;
        var selection = this.props.selection.map(function(selected, index) {
            return (
                <Chip
                    key={"selection-" + index}
                    index={index}
                    active={this.props.backspaceTarget === index}
                    label={selected.name}
                    handleRemove={this.props.removable ? this.handleRemove : null}
                    image={selected.image}/>
            );
        }.bind(this));

        if (this.props.buttonText) {
            var button = (
                <a
                    data-no-turbolinks
                    onClick={this.props.toggleModal}
                    className="btn-floating">
                    <i className="material-icons">{this.props.buttonText}</i>
                </a>
            );
        }

        if (this.props.expandable) {
            const expandableClass = this.state.expanded ? 'compress' : 'expand'
            expandableContent = (
                <i
                    className={`toggle fa fa-${expandableClass}`}
                    onClick={this.toggleExpanded}/>
            )
        }

        return (
            <div className='multiselect'>
                <div
                    className={`selection-container valign-wrapper ${expanded ? 'expanded' : null}`}
                    ref='container'>
                    {selection}
                </div>
                {button}
                {expandableContent}
            </div>
        );
    },

    scrollToBottom: function() {
        var node = ReactDOM.findDOMNode(this.refs.container);
        node.scrollTop = node.scrollHeight;
    },

    componentDidUpdate: function(prevProps, prevState) {
        if (this.props.selection !== prevProps.selection) {
            this.setState({ selection: this.props.selection });
            this.scrollToBottom();
        }

        if (prevProps.backspaceTarget !== this.props.backspaceTarget) {
            this.scrollToBottom();
        }
    }
});
