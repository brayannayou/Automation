const axios = require('axios');
const { gitlab: baseURL } = require('./config.json').urls;
const { gitlab: privateToken } = require('./config.json').tokens;
const { username: my_username } = require('./config.json');
const { gitlabProjectIds } = require('./config.json');

const axiosGL = axios.create({
  baseURL,
  headers: {
    "PRIVATE-TOKEN": privateToken,
  }
});

function getAllMergeRequests() {
  gitlabProjectIds.map(projectId => {
      const getRequestsEndpoint = `/projects/${projectId}/merge_requests/`;
      axiosGL.get(getRequestsEndpoint, {
        params: {
          state: 'opened'
        }})
        .then(({ data }) => {
            data.map(mr => {
              const { web_url, title } = mr;
              axiosGL.get(getRequestsEndpoint + `/${mr.iid}/approval_state`)
                .then(data => {
                  data.data.rules.map(rule => {
                    if (['Pay in', 'Payin'].includes(rule.name)) {
                      console.log((+rule.approved_by.length < 2 ? '\u270C ' : '\u2705'), +rule.approved_by.length, '\u270A', mr.author.username, '\u2728', title);
                      console.log(web_url);
                      console.log();
                    }
                  })
                })
            })
        })
        .catch(error => {
            console.log('error', error)
        })
  })
}

function getToApproveMergeRequests() {
    gitlabProjectIds.map(projectId => {
        const getRequestsEndpoint = `/projects/${projectId}/merge_requests/`;
        axiosGL.get(getRequestsEndpoint, {
          params: {
            state: 'opened'
          }})
          .then(({ data }) => {
              data.map(mr => {
                if (mr.author.username !== my_username) {
                  const { web_url, title } = mr;
                  axiosGL.get(getRequestsEndpoint + `/${mr.iid}/approval_state`)
                    .then(data => {
                      data.data.rules.map(rule => {
                        if (['Pay in', 'Payin'].includes(rule.name) && !rule.approved) {
                          if (rule.approved_by.some(aprove => aprove.username === my_username)) {
                            return;
                          }
                          console.log((+rule.approved_by.length < 2 ? '\u270C ' : '\u2705'), +rule.approved_by.length, '\u270A', mr.author.username, '\u2728', title);
                          console.log(web_url);
                          console.log();
                        }
                      })
                    })
                }
              })
          })
          .catch(error => {
              console.log('error', error)
          })
    })
}

function getMyMergeRequests() {
    gitlabProjectIds.map(projectId => {
        const getRequestsEndpoint = `/projects/${projectId}/merge_requests/`;
        axiosGL.get(getRequestsEndpoint, {
          params: {
            author_username: my_username,
            state: 'opened'
          }})
          .then(({ data }) => {
              data.map(mr => {
                const { web_url, title } = mr;
                axiosGL.get(getRequestsEndpoint + `/${mr.iid}/approval_state`)
                  .then(data => {
                    data.data.rules.map(rule => {
                      if (['Pay in', 'Payin'].includes(rule.name)) {
                        console.log((+rule.approved_by.length < 2 ? '\u270C ' : '\u2705'), +rule.approved_by.length, '\u270A', mr.author.username, '\u2728', title);
                        console.log(web_url);
                        console.log();
                      }
                    })
                  })
              })
          })
          .catch(error => {
              console.log('error', error)
          })
    })
}

module.exports = {
    getAllMergeRequests,
    getMyMergeRequests,
    getToApproveMergeRequests,
}
