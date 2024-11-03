# PFL_24_T03_G01 - Project 1

## Group Members
- Gonçalo Remelhe, 202205318 (60%) Implemented both the shortestPath and the travelSales function.
- Joana Noites, 202206284 (40%) Implemented the cities, areAdjacent, distance, adjacent, pathDistance, rome and isStronglyConnected functions.

## shortestPath function
To compute the sortest path between 2 given cities, 3 auxiliary functions were used: dijsktra, adjacentArray and dfsAllShortestPaths.

### Auxiliary function 1: Dijsktra

The dijsktra function finds the shortest distance between 2 cities, to do this, it converts the given roadmap to an **auxiliar data strucuture: newRoadMap**, obtained by the **roadArray** function, which stores the distances between pairs of cities if there is a road between them or Nothing if there isn't. It consists of an array of pairs that functions as a matrix, the first element of each entry is a pair of cities and the second element is the distance between them.

After converting the given roadmap to a roadArray, the dijkstra function makes use of the toCityIndex function (that returns an array of pairs in the format (city, index) ) to store the number of cities in the roadmap and the indices of the starting and target cities.

Then the arrays distanceArray and visited are created, distanceArray is used to keep track of each city and its distance from the starting city (every distance (except the distance of the starting city) is initialized as "maxbound") and visited keeps track of the cities that were already visited.

After this, the creation of an auxiliary function inside the original dijsktra function is needed, this auxiliary function is named dijsktra' and it takes the visited array and distanceArray as parameters as well as an array with only a tuple (starting city,0) that's going to serve as the start of a queue. In a nutshell, this auxiliary function: 1.Finds the city with the shortest distance relatively to the starting city (the second element of the pairs in the queue), 2.removes it from the queue, 3.marks that city as visited, 4.finds the unvisited neighbours of that city, 5.updates their distances in relation to the starting city, 6. updates the queue and finally 7. continues recursively with a new queue and a new distance array until the queue is empty and finally 8. returns the distance to the target city. The return value of this auxiliary function is the return value of the original dijsktra function, however a check is ran to see if it is equal to the "maxbound" defined in the distance array, if so, dijsktra returns Nothing, as this means that the target city is not accessible from the starting city.

### Auxiliary function 2: adjacentArray

adjacentArray is a different approach to the adjacent function, the difference being that it uses the auxiliar data structure newRoadMap defined by the **roadArray** function explained above.

### Auxiliary function 3: dfsAllShortestPaths

This function uses Depth-First search to find all the shortest paths between 2 cities. It uses the auxiliar data structure newRoadMap, the cityIndex array obtained from the tocityindex function, the indexes from the starting and ending city, as well as the return value of the dijkstra function mentioned above. This function performs depth first search and registers the paths from the starting city to the ending city, when a path is concluded, it is checked if its distance is longer than the value returned by dijsktra (mindist), if so, the path is discarded, otherwise, the path is saved and more paths are calculated recursively until (nao percebi aqui como é que sabemos quando paramos de descobrir paths). Then all the shortest paths are returned as an array of arrays of pairs. 

### Result

Finally, with all these auxiliary functions defined the shortestPath function can calculate the minimum distance using dijsktra and find all the paths from the starting city to the ending city measuring the minimum distance with the use of the dfsAllShortestPaths (that uses the adjacent array for the path searching).

## travelSales function

### Auxiliary function 1: tsp
This function uses dynamic programming and bit masking to solve the travelling salesperson problem, it is the body of the travelSales function and takes the following parameters: a **newRoadMap**, the number of cities, a bitmask marking the represented cities, the current position of the TSP traversal and a dynamic table that stores previously calculated optimal paths.

Firstly, the base case checks if all cities were visited, if so, the function returns the current path, keeping in mind that we need to return to the starting city at the end

### Result





