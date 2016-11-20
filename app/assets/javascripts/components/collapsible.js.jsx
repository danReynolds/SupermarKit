class Collapsible extends React.Component {
  static propTypes = {
    children: React.PropTypes.array,
    className: React.PropTypes.string,
    key: React.PropTypes.string,
  }

  constructor(props) {
    super(props);

    this.state = {
      expanded: false,
    };

    this.toggleExpanded = this.toggleExpanded.bind(this);
  }

  toggleExpanded() {
    const { expanded } = this.state;
    this.setState({ expanded: !expanded });
  }

  render() {
    const { children, className, key } = this.props;
    const { expanded } = this.state;
    const icon = expanded ? 'chevron-down' : 'chevron-right';

    return (
      <li
        className={className}
        key={key}
      >
        <div
            onClick={this.toggleExpanded}
            className='collapsible-header'
        >
          <i className={`fa fa-${icon}`}/>
          {children[0].props.children}
        </div>
        <div className='collapsible-body'>
          {children[children.length - 1].props.children}
        </div>
      </li>
    );
  }
}
