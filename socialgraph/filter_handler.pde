class GraphFilter {
  String _name; // name of filter
	private int _id;
  int _order; // order amongst other filters (0...n)
  private ArrayList<Person> _people; // people collected by this filter
  // range of total degree
  int _min_degree = -1; 
  int _max_degree = -1;
  // range of degree to previous filtered set.
  int _min_degree_curr_to_prev = -1;
  int _max_degree_curr_to_prev = -1;
  // range of degree from previous filtered set.
  int _min_degree_curr_from_prev = -1;
  int _max_degree_curr_from_prev = -1;
  
  GraphFilter(int id, String name, int order) {
		_id = id;
    _name = name;
    _order = order;
    _people = new ArrayList<Person>();
  }
  
	/* load new filter settings
	 *
	 */
  public void load(int min_degree, int max_degree, int min_degree_curr_to_prev, int max_degree_curr_to_prev, int min_degree_curr_from_prev, int max_degree_curr_from_prev, GraphFilter prev_filter) {
   String required_connections_set = "";
   _min_degree = min_degree;
   _max_degree = max_degree;
   _min_degree_curr_to_prev = min_degree_curr_to_prev;
   _max_degree_curr_to_prev = max_degree_curr_to_prev;
   _min_degree_curr_from_prev = min_degree_curr_from_prev;
   _max_degree_curr_from_prev = max_degree_curr_from_prev;
   
  // look up the previous filter
  if( prev_filter != null) {
		for(int i = 0; i < prev_filter.size(); i ++) {
			if(i == 0) {
				required_connections_set += prev_filter.get(i).getID();
			} else {
				required_connections_set += "," + prev_filter.get(i).getID();
			}
		}
	} else {
		required_connections_set = "-1";
	}
   
	// TODO: can tables be returned by the database, which can then be querried?
   // query the database
   _people = dbm.peopleWithConnections(_min_degree,_max_degree, false, required_connections_set);
   println("GraphFilter:load loaded " + _people.size() + " nodes into filter \"" + _name + "\"");
  }
  
  /* get a person. return null if index is invalid
   *
   */
  public Person get(int index) {
    if(index < _people.size() && index >= 0) {
      return _people.get(index);
    } else {
      return null;
    }
  }
  
  /* return how many people are in this filter
   *
   */
  public int size() {
    return _people.size();
  }
	
	public int getOrder() {
		return _order;
	}
	
	/* get the name of the filter
	 *
	 */
	public String name() {
		return _name;
	}
	
	/* return the filtered data set as a list of connections
	 * TODO: do we need this??
	 */
	public ArrayList<Connection> toConnections() {
		ArrayList<Connection> con = new ArrayList<Connection>();
		for(int i = 0; i < _people.size(); i ++) {
			con.add(new Connection(_people.get(i).getID(), true));
		}
		return con;
	}
}

/* Class to handle the filters
 *
 */
class FilterManager {
  private ArrayList<GraphFilter> _filters;
  private Boolean _updated;
  private int _id_tic = -1; // id ticker for internal filter filter

  FilterManager() {
    _filters = new ArrayList<GraphFilter>();
    _updated = false;
  }
  
  /* create a new empty filter
   *
   */
  public void addFilter() {
    // initialize new filter with default name and order
    _filters.add(new GraphFilter(generateID(),"filter " + _filters.size(), _filters.size()));
  }
  
	/* generate a unique id for the filter
	 *
	 */
	private int generateID() {
		return _id_tic ++;
	}

  /* return number of filters
   *
   */
  public int size() {
    
    return _filters.size();
  }
  
  /* get a filter
   *
   */
  public GraphFilter get(int index) {
		if(index >= 0 && index < size()) {
			return _filters.get(index);
		} else {
			return null;
		}
  }
  
  /* erase all of the filters
   *
   */
  public void clear() {
    _filters = new ArrayList<GraphFilter>();
    _updated = true;
  }
  
	/* there are changes. network needs update
	 *
	 */
  public void makeDirty() {
		_updated = true;
  }

	/* there are no more changes. network is fine
	 *
	 */
	public void makeClean() {
		_updated = false;
	}
	
	/* check if there are any changes
	 *
	 */
	public boolean isClean() {
		return _updated;
	}
}
