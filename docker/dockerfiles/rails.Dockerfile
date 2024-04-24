FROM chatwoot:development

RUN chmod +x docker/entrypoints/rails.sh

EXPOSE 3002
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3002"]