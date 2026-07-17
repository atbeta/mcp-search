FROM python:3.12-slim

RUN pip install --no-cache-dir "mcp[cli]==1.13.0" requests

COPY server.py /srv/server.py
WORKDIR /srv

ENV SEARXNG_URL=http://searxng:8080
ENV MCP_PORT=8001

EXPOSE 8001
USER 1000:1000
CMD ["python", "/srv/server.py"]
